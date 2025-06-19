module api.dm.gui.controls.texts.buffers.array_text_buffer;

import api.dm.gui.controls.texts.buffers.base_text_buffer : BaseTextBuffer;
import api.dm.kit.assets.fonts.glyphs.glyph : Glyph;

import core.stdc.stdlib;
import core.stdc.string;

/**
 * Authors: initkfs
 */
class ArrayTextBuffer(T = Glyph) : BaseTextBuffer!T
{
    T[] _buffer;

    override bool create(const(dchar)[] text)
    {
        if (text.length == 0)
        {
            return false;
        }

        if (!super.create(text))
        {
            return false;
        }

        length = 0;

        if (_buffer.length < text.length)
        {
            const newCapacity = text.length;
            const newSizeBytes = newCapacity * T.sizeof;
            T* bufferPtr;
            if (_buffer.length > 0)
            {
                bufferPtr = cast(T*) realloc(_buffer.ptr, newSizeBytes);
            }
            else
            {
                bufferPtr = cast(T*) malloc(newSizeBytes);
            }

            if (!bufferPtr)
            {
                return false;
            }

            _buffer = bufferPtr[0 .. text.length];
        }

        assert(itemProvider);

        //TODO check prev buffer size?

        foreach (i, ch; text)
        {
            _buffer[i] = itemProvider(ch);
        }

        length = text.length;

        return true;
    }

    override bool destroy()
    {
        if (_buffer.length > 0)
        {
            free(_buffer.ptr);
            return true;
        }
        return false;
    }

    override bool insert(size_t pos, const(dchar)[] text)
    {
        if (text.length == 0)
        {
            return false;
        }

        T[] glyphs = (cast(T*) malloc(T.sizeof * text.length))[0 .. text.length];
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
            glyphs[i] = itemProvider(ch);
        }

        return insert(pos, glyphs);
    }

    override bool insert(size_t pos, T[] text)
    {
        if (pos > length)
        {
            return false;
        }

        size_t newLen = length + text.length;
        if (newLen > _buffer.length)
        {
            size_t newCapacity = _buffer.length * 2;
            newLen = newCapacity > newLen ? newCapacity : newLen;
            auto newPtr = cast(T*) realloc(_buffer.ptr, newLen * Glyph.sizeof);
            if (!newPtr)
            {
                return false;
            }
            _buffer = newPtr[0 .. newLen];
        }

        size_t insertPos = length > 0 ? pos + 1 : 0;

        if (insertPos != length && length > 0)
        {
            ptrdiff_t rest = length - pos - 1;
            memmove(&_buffer[insertPos + text.length], &_buffer[insertPos], rest * T.sizeof);
        }

        foreach (i, ch; text)
        {
            _buffer[i + insertPos] = ch;
        }

        length += text.length;

        return true;
    }

    size_t removeNext(size_t pos, size_t removeCount)
    {
        if (removeCount == 0 || pos + removeCount > length)
        {
            return 0;
        }

        if (pos == 0 && length == removeCount)
        {
            length = 0;
            return removeCount;
        }

        auto rightIndex = pos + removeCount;
        size_t rest = length - rightIndex;

        if (rest > 0)
        {
            memmove(&_buffer[pos], &_buffer[rightIndex], rest * Glyph.sizeof);
        }

        length -= removeCount;

        return removeCount;
    }

    override size_t removePrev(size_t pos, size_t removeCount)
    {
        if (length == 0 || removeCount == 0)
        {
            return 0;
        }

        const lastIndex = length - 1;

        if (pos > lastIndex && removeCount - 1 > pos)
        {
            return 0;
        }

        if (pos == lastIndex)
        {
            length -= removeCount;
            return removeCount;
        }

        length -= removeCount;

        size_t rest = lastIndex - pos;

        memmove(&_buffer[pos - (removeCount - 1)], &_buffer[pos + 1], rest * T.sizeof);

        return removeCount;
    }

    override inout(T[]) buffer() inout => _buffer[0 .. length];

    override dstring text()
    {
        import std.algorithm.iteration : map;
        import std.conv : to;

        return buffer.map!(glyph => glyph.grapheme)
            .to!dstring;
    }
}

unittest
{
    auto textBuff = new ArrayTextBuffer!Glyph;
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
    auto textBuff = new ArrayTextBuffer!Glyph;
    dstring text = "Hello world";

    textBuff.create(text);
    assert(textBuff.removeNext(0, text.length) == text.length);

    textBuff.create(text);
    assert(textBuff.removeNext(0, 6) == 6);
    assert(textBuff.text == "world");
    assert(textBuff.removeNext(0, 2) == 2);
    assert(textBuff.text == "rld");
    assert(textBuff.removeNext(0, 3) == 3);
    assert(textBuff.text == "");

    textBuff.create(text);
    assert(textBuff.removeNext(0, 1) == 1);
    assert(textBuff.text == "ello world");

    textBuff.create(text);
    assert(textBuff.removeNext(text.length - 1, 1) == 1);
    assert(textBuff.text == "Hello worl");
}

unittest
{
    auto textBuff = new ArrayTextBuffer!Glyph;
    dstring text = "Hello world";

    textBuff.create(text);
    assert(textBuff.removePrev(10, text.length) == text.length);
    assert(textBuff.text == "");

    textBuff.create(text);
    assert(textBuff.removePrev(6, 4) == 4);
    assert(textBuff.text == "Helorld");

    textBuff.create(text);
    assert(textBuff.removePrev(5, 1) == 1);
    assert(textBuff.text == "Helloworld");

    textBuff.create(text);
    assert(textBuff.removePrev(10, 6) == 6);
    assert(textBuff.text == "Hello");
    assert(textBuff.removePrev(4, 3) == 3);
    assert(textBuff.text == "He");
    assert(textBuff.removePrev(1, 2) == 2);
    assert(textBuff.text == "");

    textBuff.create("Hello");
    assert(textBuff.removePrev(4, 1) == 1);
    assert(textBuff.removePrev(3, 1) == 1);
    assert(textBuff.removePrev(2, 1) == 1);
    assert(textBuff.removePrev(1, 1) == 1);
    assert(textBuff.text == "H");
    assert(textBuff.removePrev(0, 1) == 1);
    assert(textBuff.text == "");

    textBuff.create("H");
    assert(textBuff.removePrev(0, 1) == 1);
    assert(textBuff.text == "");
}
