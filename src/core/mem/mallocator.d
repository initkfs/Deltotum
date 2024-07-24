module core.mem.mallocator;

import core.mem.unique_ptr : UniqPtr;

/**
 * Authors: initkfs
 */

import core.stdc.stdlib : malloc, realloc, free;

ubyte[] allocate(size_t sizeBytes) @nogc nothrow @safe
{
    return (() @trusted {
        void* newPtr = malloc(sizeBytes);
        assert(newPtr);
        return cast(ubyte[]) newPtr[0 .. sizeBytes];
    })();
}

bool reallocate(scope ref ubyte[] ptr, size_t newBytes) @nogc nothrow @safe
{
    return (() @trusted {
        void* newPtr = realloc(ptr.ptr, newBytes);
        assert(newPtr);
        ptr = cast(ubyte[]) newPtr[0 .. newBytes];
        return true;
    })();
}

static bool deallocate(scope ubyte[] ptr) @nogc nothrow @safe
{
    return (() @trusted { free(ptr.ptr); return true; })();
}

version (D_BetterC)
{
}
else
{
    import core.mem.allocator : uniq, Allocator, AllocFuncType, FreeFuncType, ReallocFuncType;

    class Mallocator : Allocator
    {
        static this()
        {
            allocFunPtr = &allocate;
            reallocFunPtr = &reallocate;
            freeFunPtr = &deallocate;
        }
    }
}

unittest
{
    import MemAllocator = core.mem.allocator;

    MemAllocator.allocFunPtr = &allocate;
    MemAllocator.reallocFunPtr = &reallocate;
    MemAllocator.freeFunPtr = &deallocate;

    UniqPtr!int intPtr1 = MemAllocator.uniq!int;
    intPtr1 = 5;
    assert(intPtr1.value == 5);

    version (D_BetterC)
    {
    }
    else
    {
        auto mCl2 = new Mallocator;
        auto intPtr2 = mCl2.uniq!int;
        intPtr2 = 5;
        assert(intPtr2.value);
    }
}
