module api.core.mem.allocator;

import api.core.mem.unique_ptr : UniqPtr;

/**
 * Authors: initkfs
 */

alias AllocFuncType = bool function(size_t sizeBytes, scope ref void[] ptr) @nogc nothrow @safe;
alias FreeFuncType = bool function(scope void[] ptr) @nogc nothrow @safe;
alias ReallocFuncType = bool function(size_t newSizeBytes, scope ref void[]) @nogc nothrow @safe;

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

    UniqPtr!T uniq(T)(size_t capacity = 1, bool isAutoFree = true, bool isErrorOnFail = true)
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

        void[] ptr;
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

        T[] newPtr = cast(T[]) ptr;
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
