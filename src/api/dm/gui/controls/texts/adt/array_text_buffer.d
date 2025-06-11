module api.dm.gui.controls.texts.adt.array_text_buffer;

import api.dm.kit.assets.fonts.glyphs.glyph : Glyph;

import core.stdc.stdlib;
import core.stdc.string;

/**
 * Authors: initkfs
 */
struct ArrayTextBuffer
{
    Glyph[] _buffer;
    size_t count;

    Glyph delegate(dchar) glyphProvider;

    bool create(const(dchar)[] text)
    {
        if (!glyphProvider)
        {
            glyphProvider = (ch) => Glyph(ch);
        }

        count = 0;
        if (_buffer.length > 0)
        {
            free(_buffer.ptr);
        }

        _buffer = (cast(Glyph*) malloc(text.length * Glyph.sizeof))[0 .. text.length];

        size_t pos;
        foreach (ch; text)
        {
            _buffer[pos] = glyphProvider(ch);
            pos++;
        }

        count = text.length;

        return true;
    }

    bool destroy()
    {
        free(_buffer.ptr);
        return true;
    }

    void onGlyphs(scope bool delegate(Glyph*, size_t) onGlyphDg)
    {
        foreach (i, ref glyph; _buffer[0 .. count])
        {
            if (!onGlyphDg(&glyph, i))
            {
                break;
            }
        }
    }

    bool insert(size_t pos, const(dchar)[] text)
    {
        if (text.length == 0)
        {
            return false;
        }

        Glyph[] glyphs = (cast(Glyph*) malloc(Glyph.sizeof * text.length))[0 .. text.length];
        if (glyphs.length == 0)
        {
            return false;
        }

        scope (exit)
        {
            free(glyphs.ptr);
        }

        foreach (i, dchar ch; text)
        {
            glyphs[i] = glyphProvider(ch);
        }

        return insert(pos, glyphs);
    }

    bool insert(size_t pos, Glyph[] text)
    {
        if (pos > count)
        {
            return false;
        }

        size_t newLen = count + text.length;
        if (newLen > _buffer.length)
        {
            size_t newCapacity = _buffer.length * 2;
            newLen = newCapacity > newLen ? newCapacity : newLen;
            auto newPtr = cast(Glyph*) realloc(_buffer.ptr, newLen * Glyph.sizeof);
            if (!newPtr)
            {
                return false;
            }
            _buffer = newPtr[0 .. newLen];
        }

        size_t insertPos = count > 0 ? pos + 1 : 0;

        if (insertPos != count && count > 0)
        {
            ptrdiff_t rest = count - pos - 1;
            memmove(&_buffer[insertPos + text.length], &_buffer[insertPos], rest * Glyph.sizeof);
        }

        foreach (i, ch; text)
        {
            _buffer[i + insertPos] = ch;
        }

        count += text.length;

        return true;
    }

    size_t remove(size_t pos, size_t removeCount)
    {
        if (removeCount == 0 || pos + removeCount > count)
        {
            return 0;
        }

        if (count == removeCount)
        {
            count = 0;
            return removeCount;
        }

        auto rightIndex = pos + removeCount;
        size_t rest = count - rightIndex;

        if (rest > 0)
        {
            memmove(&_buffer[pos], &_buffer[rightIndex], rest * Glyph.sizeof);
        }

        count -= removeCount;

        return removeCount;
    }

    inout(Glyph[]) buffer() inout => _buffer[0 .. count];

    dstring text()
    {
        import std.algorithm.iteration : map;
        import std.conv : to;

        return buffer.map!(glyph => glyph.grapheme)
            .to!dstring;
    }

    Glyph*[] newGlyphsPtr()
    {
        if (count == 0)
        {
            return null;
        }

        Glyph** bufPtr = cast(Glyph**) malloc(count * (Glyph*).sizeof);
        if (!bufPtr)
        {
            return null;
        }

        Glyph*[] buffer = bufPtr[0 .. count];
        foreach (i, ref g; _buffer[0 .. count])
        {
            buffer[i] = &g;
        }

        return buffer;
    }

    size_t glyphsCount() => count;
}

unittest
{
    ArrayTextBuffer textBuff;
    dstring text = "Hello world\n";
    textBuff.create(text);

    assert(textBuff.buffer.length == text.length);
    assert(textBuff.text == text);

    assert(textBuff.insert(5, "awesome "));
    assert(textBuff.text == "Hello awesome world\n");

    textBuff.create("H");
    textBuff.insert(0, "e");
    textBuff.insert(1, "l");
    textBuff.insert(2, "l");
    textBuff.insert(3, "o");
    assert(textBuff.text == "Hello");

    textBuff.create("");
    textBuff.insert(0, "Hello");

    textBuff.create("Hel");
    textBuff.insert(2, "lo");
    assert(textBuff.text == "Hello");
}

unittest
{
    ArrayTextBuffer textBuff;
    dstring text = "Hello world";

    textBuff.create(text);
    assert(textBuff.remove(0, text.length) == text.length);

    textBuff.create(text);
    assert(textBuff.remove(0, 6) == 6);
    assert(textBuff.text == "world");
    assert(textBuff.remove(0, 2) == 2);
    assert(textBuff.text == "rld");
    assert(textBuff.remove(0, 3) == 3);
    assert(textBuff.text == "");

    textBuff.create(text);
    assert(textBuff.remove(0, 1) == 1);
    assert(textBuff.text == "ello world");

    textBuff.create(text);
    assert(textBuff.remove(text.length - 1, 1) == 1);
    assert(textBuff.text == "Hello worl");
}
