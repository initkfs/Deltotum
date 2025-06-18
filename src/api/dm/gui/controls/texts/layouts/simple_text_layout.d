module api.dm.gui.controls.texts.layouts.simple_text_layout;

import core.stdc.stdlib : malloc, free, realloc;
import std.conv : to;

/**
 * Authors: initkfs
 */
struct SimpleTextLayout
{
    alias Type = size_t;

    private
    {
        Type[] _lineBreaks;
        size_t _length;
    }

    size_t initCapacity = 1;
    size_t growFactor = 2;

    ~this()
    {
        destroy;
    }

    bool create() nothrow @nogc
    {
        if (isCreated)
        {
            destroy;
        }

        assert(initCapacity > 0);

        auto buffPtr = cast(Type*) malloc(initCapacity * Type.sizeof);
        if (!buffPtr)
        {
            return false;
        }

        _lineBreaks = buffPtr[0 .. initCapacity];
        reset;

        return true;
    }

    bool isCreated() const @nogc nothrow @safe => _lineBreaks.length > 0;

    bool destroy() nothrow @nogc
    {
        if (isCreated)
        {
            free(_lineBreaks.ptr);
            return true;
        }

        return false;
    }

    void opOpAssign(string op : "~")(Type rhs) nothrow @nogc
    {
        if (!isCreated && !create)
        {
            assert(false, "Error creating text layout buffer");
        }

        const newSize = _length + 1;

        if (newSize >= _lineBreaks.length && !grow(growFactor, newSize))
        {
            assert(false, "Error text layout buffer growing");
        }

        _lineBreaks[_length] = rhs;
        _length++;
    }

    bool grow(size_t factor, size_t needSize) nothrow @nogc
    {
        assert(factor > 0);
        assert(needSize > 0);

        size_t newCapacity = _lineBreaks.length * factor;
        if (newCapacity / factor != _lineBreaks.length)
        {
            return false;
        }

        if (needSize > newCapacity)
        {
            newCapacity = needSize;
        }

        auto newBufferPtr = cast(Type*) realloc(_lineBreaks.ptr, newCapacity * Type.sizeof);
        if (!newBufferPtr)
        {
            return false;
        }

        _lineBreaks = newBufferPtr[0 .. newCapacity];
        return true;
    }

    void reset() nothrow @nogc @safe
    {
        _length = 0;
    }

    inout(size_t[]) lineBreaks() return scope inout nothrow @nogc @safe => _lineBreaks[0 .. _length];
}

unittest
{
    SimpleTextLayout layout;
    assert(layout.create);
    assert(layout.lineBreaks.length == 0);

    layout ~= 10;
    assert(layout.lineBreaks.length == 1);
    assert(layout.lineBreaks == [10]);

    layout ~= 20;
    assert(layout.lineBreaks.length == 2);
    assert(layout.lineBreaks == [10, 20]);
}
