module api.core.utils.text;

import std.uni : isControl;
import std.traits : isSomeChar, Unqual;
import std.utf : decode;
import std.stdio;

import std.traits : isAutodecodableString, isSomeChar;
import std.range.primitives : isInputRange, ElementEncodingType;
import api.dm.addon.math.geom2.triangulations.fortune;

bool isUnwant(dchar ch) nothrow @nogc pure @safe
{
    import std.uni : isControl;

    if (isControl(ch))
    {
        return true;
    }

    //'<','>','&','"','\''

    static immutable(dchar[]) bidiChars = [
        '\u061C',
        '\u200E',
        '\u200F',
        '\u202A',
        '\u200B',
        '\u202B',
        '\u202C',
        '\u202D',
        '\u202E',
        '\u2066',
        '\u2067',
        '\u2068',
        '\u2069'
    ];

    foreach (bch; bidiChars)
    {
        if (ch == bch)
        {
            return true;
        }
    }

    return false;
}

//TODO const(S)[] --> string
const(S)[] escapeunw(S, bool isNormalize = false)(const(S)[] input,
    dstring escapeSymbol = "\\n",
    size_t maxSize = size_t.max,
    const(S)[] truncateEnd = "...",
    bool function(dchar) unwantTestFunc = &isUnwant) if (isSomeChar!S)
{
    assert(unwantTestFunc);

    static if (isNormalize)
    {
        import std.uni : normalize;

        input = input.normalize;
    }

    input = truncate(input, maxSize, truncateEnd);

    if (input.length == 0)
    {
        return null;
    }

    import std.utf : byUTF;
    import std.conv : to;
    import core.stdc.stdlib : malloc, free;

    alias OutType = dchar;

    OutType[] buffer;
    scope (exit)
    {
        if (buffer.length > 0)
        {
            free(&buffer[0]);
        }
    }

    const escapeLen = escapeSymbol.length;

    size_t bufferPos;
    size_t inputPos;
    foreach (OutType ch; input.byUTF!OutType)
    {
        if (unwantTestFunc(ch))
        {
            if (buffer.length == 0)
            {
                const maxBufferSize = input.length * escapeLen;
                void* buffPtr = malloc(OutType.sizeof * maxBufferSize);
                assert(buffPtr);
                buffer = (cast(OutType*) buffPtr)[0 .. maxBufferSize];

                import std.range : take;
                import std.algorithm.mutation : copy;

                copy(input.byUTF!OutType.take(inputPos), buffer[0 .. inputPos]);
                bufferPos += inputPos;
            }

            buffer[bufferPos .. (bufferPos + escapeLen)] = escapeSymbol;
            bufferPos += escapeLen;
            continue;
        }

        if (buffer.length > 0)
        {
            buffer[bufferPos] = ch;
            bufferPos++;
        }
        else
        {
            inputPos++;
        }
    }

    if (buffer.length == 0)
    {
        return input;
    }

    return buffer[0 .. bufferPos].to!(typeof(return));
}

unittest
{
    assert(escapeunw("") == "");
    assert(escapeunw("h") == "h");
    assert(escapeunw("helloworld") == "helloworld");
    assert(escapeunw("hello world") == "hello world");

    assert(escapeunw("\nhello world\r\n") == "\\nhello world\\n\\n");
    assert(escapeunw("Back\x08Space") == "Back\\nSpace");
    assert(escapeunw("Delete\x7FMe") == "Delete\\nMe");
    assert(escapeunw("\x01\x02\x03") == "\\n\\n\\n");
    assert(escapeunw("he\u2066llo") == "he\\nllo");
}

S truncate(S)(S input, size_t maxLength, S strEnd = "...")
{
    if (input.length == 0 || maxLength == 0)
    {
        return null;
    }
    return input.length > maxLength ? (input[0 .. maxLength] ~ strEnd) : input;
}

unittest
{
    assert(truncate("", size_t.max) == "");
    assert(truncate("hello", 0) == "");
    assert(truncate("hello world", 6) == "hello ...");
}
