module app.core.mem.allocator;

import app.core.mem.unique_ptr : UniqPtr;

/**
 * Authors: initkfs
 */

alias AllocFuncType = void[]function(size_t sizeBytes) @nogc nothrow @trusted;
alias FreeFuncType = bool function(scope void[] ptr) @nogc nothrow @trusted;
alias ReallocFuncType = bool function(scope ref void[], size_t newSizeBytes) @nogc nothrow @trusted;

mixin template MemFuncs()
{
    static
    {
        AllocFuncType allocFunPtr;
        ReallocFuncType reallocFunPtr;
        FreeFuncType freeFunPtr;
    }

    UniqPtr!T uptr(T)(size_t capacity = 1, bool isAutoFree = true)
    in (allocFunPtr)
    {
        assert(capacity > 0);
        auto size = capacity * T.sizeof;
        assert((size / capacity) == T.sizeof, "Allocation size overflow");

        T[] newPtr = cast(T[]) allocFunPtr(size);
        assert(newPtr.length == capacity);

        return UniqPtr!T(newPtr, isAutoFree, freeFunPtr, reallocFunPtr);
    }
}

abstract class Allocator
{
    mixin MemFuncs;
}
