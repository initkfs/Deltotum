module api.util.allocs.allocator;

import api.util.ptrs.unique_ptr : UniqPtr;

/**
 * Authors: initkfs
 */

alias AllocFuncType(T) = bool function(size_t size, scope ref T[] ptr) nothrow @safe;
alias ReallocFuncType(T) = bool function(size_t newSize, scope ref T[]) nothrow @safe;
alias FreeFuncType(T) = bool function(scope T[] ptr) @nogc nothrow @safe;

mixin template MemFuncs(T)
{
    version (D_BetterC)
    {
        __gshared
        {
            AllocFuncType!T allocFunPtr;
            ReallocFuncType!T reallocFunPtr;
            FreeFuncType!T freeFunPtr;
        }
    }
    else
    {
        AllocFuncType!T allocFunPtr;
        ReallocFuncType!T reallocFunPtr;
        FreeFuncType!T freeFunPtr;
    }

    UniqPtr!U uniq(U)(size_t capacity = 1, bool isAutoFree = true, bool isErrorOnFail = true)
    in (allocFunPtr)
    {
        if (capacity == 0)
        {
            enum message = "Capacity must not be zero";
            version (D_Exceptions)
            {
                throw new Exception(message);
            }
            else
            {
                assert(false, message);
            }
        }

        const size = capacity * T.sizeof;

        if ((size / capacity) != T.sizeof)
        {
            enum message = "Allocation size overflow";
            version (D_Exceptions)
            {
                throw new Exception(message);
            }
            else
            {
                assert(false, message);
            }

        }

        T[] ptr;
        if (!allocFunPtr(size, ptr) && isErrorOnFail)
        {
            enum message = "Allocation failed";
            version (D_Exceptions)
            {
                throw new Exception(message);
            }
            else
            {
                assert(false, message);
            }
        }

        U[] newPtr = cast(U[]) ptr;
        assert(newPtr.length == capacity);

        return UniqPtr!U(newPtr, isAutoFree, freeFunPtr, reallocFunPtr);
    }
}

version (D_BetterC)
{
    mixin MemFuncs!ubyte;
}
else
{
    abstract class Allocator(T)
    {
        mixin MemFuncs!T;

        bool canAlloc() const nothrow pure @safe => true;
    }
}
