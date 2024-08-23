module api.core.mem.allocator;

import api.core.mem.unique_ptr : UniqPtr;

/**
 * Authors: initkfs
 */

alias AllocFuncType = void[] function(size_t sizeBytes) @nogc nothrow @safe;
alias FreeFuncType = bool function(scope void[] ptr) @nogc nothrow @safe;
alias ReallocFuncType = bool function(scope ref void[], size_t newSizeBytes) @nogc nothrow @safe;

mixin template MemFuncs()
{
    version (D_BetterC)
    {
        __gshared
        {
            AllocFuncType allocFunPtr;
            ReallocFuncType reallocFunPtr;
            FreeFuncType freeFunPtr;
        }
    }
    else
    {
        static
        {
            AllocFuncType allocFunPtr;
            ReallocFuncType reallocFunPtr;
            FreeFuncType freeFunPtr;
        }
    }

    UniqPtr!T uniq(T)(size_t capacity = 1, bool isAutoFree = true)
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

mixin MemFuncs;

version (D_BetterC)
{
}
else
{
    abstract class Allocator
    {
        mixin MemFuncs;
    }
}
