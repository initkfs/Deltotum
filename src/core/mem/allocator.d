module core.mem.allocator;

import core.mem.unique_ptr : UniqPtr;

/**
 * Authors: initkfs
 */

alias AllocFuncType(T) = T[]function(size_t sizeBytes) @nogc nothrow @safe;
alias FreeFuncType(T) = bool function(scope T[]) @nogc nothrow @safe;
alias ReallocFuncType(T) = bool function(scope ref T[], size_t newSizeBytes) @nogc nothrow @safe;

mixin template MemFuncs()
{
    version (D_BetterC)
    {
        __gshared
        {
            AllocFuncType!ubyte allocFunPtr;
            ReallocFuncType!ubyte reallocFunPtr;
            FreeFuncType!ubyte freeFunPtr;
        }
    }
    else
    {
        static
        {
            AllocFuncType!ubyte allocFunPtr;
            ReallocFuncType!ubyte reallocFunPtr;
            FreeFuncType!ubyte freeFunPtr;
        }
    }

    static T[] allocateT(T)(size_t sizeBytes) @nogc nothrow @safe
    {
        return (() @trusted {
            assert(sizeBytes >= T.sizeof);

            T[] ptr = cast(T[]) allocFunPtr(sizeBytes);
            return ptr;
        })();
    }

    static bool reallocateT(T)(scope ref T[] ptr, size_t newSizeBytes) @nogc nothrow @safe
    {
        return (() @trusted {
            assert(newSizeBytes >= T.sizeof);

            ubyte[] oldPtr = cast(ubyte[]) ptr;
            bool isRealloc = reallocFunPtr(oldPtr, newSizeBytes);
            ptr = cast(T[]) oldPtr[0 .. newSizeBytes];
            return isRealloc;
        })();
    }

    static bool deallocateT(T)(scope T[] ptr) @nogc nothrow @safe
    {
        return (() @trusted { return freeFunPtr(cast(ubyte[]) ptr); })();
    }

    UniqPtr!T uniq(T)(size_t capacity = 1, bool isAutoFree = true)
    in (allocFunPtr)
    {
        assert(capacity > 0);
        auto size = capacity * T.sizeof;
        assert((size / capacity) == T.sizeof, "Allocation size overflow");

        T[] newPtr = allocateT!T(size);
        assert(newPtr.length == capacity);

        return UniqPtr!T(newPtr, isAutoFree, &deallocateT!T, &reallocateT!T);
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

        UniqPtr!ubyte uniqb(size_t capacity = 1, bool isAutoFree = true)
        {
            ubyte[] ptr = allocateT!ubyte(capacity);
            return UniqPtr!ubyte(ptr, isAutoFree, freeFunPtr, reallocFunPtr);
        }
    }
}
