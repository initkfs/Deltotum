module app.core.mem.mallocator;

import app.core.mem.unique_ptr : UniqPtr;

/**
 * Authors: initkfs
 */

import core.stdc.stdlib : malloc, realloc, free;

void[] allocate(size_t sizeBytes) @nogc nothrow @safe
{
    return (() @trusted {
        void* newPtr = malloc(sizeBytes);
        assert(newPtr);
        return newPtr[0 .. sizeBytes];
    })();
}

bool reallocate(scope ref void[] ptr, size_t newBytes) @nogc nothrow @safe
{
    return (() @trusted {
        void* newPtr = realloc(ptr.ptr, newBytes);
        assert(newPtr);
        ptr = newPtr[0 .. newBytes];
        return true;
    })();
}

static bool deallocate(scope void[] ptr) @nogc nothrow @safe
{
    return (() @trusted { free(ptr.ptr); return true; })();
}

version (D_BetterC)
{
}
else
{
    import app.core.mem.allocator : uniq, Allocator, AllocFuncType, FreeFuncType, ReallocFuncType;

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
    import MemAllocator = app.core.mem.allocator;

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
