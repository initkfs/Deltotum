module api.core.utils.allocs.allocator;

import api.core.utils.ptrs.unique_ptr : UniqPtr;
import api.core.utils.ptrs.shared_ptr : SharedPtr;

/**
 * Authors: initkfs
 */

alias AllocFuncType(T) = bool function(size_t size, scope ref T[] ptr) nothrow @safe;
alias ReallocFuncType(T) = bool function(size_t newSize, scope ref T[]) nothrow @safe;
alias FreeFuncType(T) = bool function(scope T[] ptr) @nogc nothrow @safe;

mixin template MemFuncs(T = ubyte)
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

    U[] rawptr(U)(size_t capacity = 1, bool isErrorOnFail = true)
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

        const size = capacity * U.sizeof;

        if ((size / capacity) != U.sizeof)
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

        static if (T.sizeof != 1)
        {
            size = size / T.sizeof;

            if (size == 0)
            {
                enum message = "Allocation native size is zero";
                version (D_Exceptions)
                {
                    throw new Exception(message);
                }
                else
                {
                    assert(false, message);
                }
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

        return newPtr;
    }

    UniqPtr!(U, T) uniqptr(U)(size_t capacity = 1, bool isAutoFree = true, bool isErrorOnFail = true)
    in (allocFunPtr)
    {

        return UniqPtr!(U, T)(rawptr!U(capacity, isErrorOnFail), isAutoFree, freeFunPtr, reallocFunPtr);
    }

    UniqPtr!(U, T) sharedptr(U)(size_t capacity = 1, bool isErrorOnFail = true)
    in (allocFunPtr)
    {
        return SharedPtr!(U, T)(rawptr!U(capacity, isErrorOnFail), allocFunPtr, freeFunPtr, reallocFunPtr);
    }
}

version (D_BetterC)
{
    mixin MemFuncs!ubyte;
}
else
{
    abstract class Allocator(T = ubyte)
    {
        mixin MemFuncs!T;

        bool canAlloc() const nothrow pure @safe => true;
    }
}
