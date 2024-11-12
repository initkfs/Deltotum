module api.core.mems.allocs.mallocator;

import api.core.mems.ptrs.unique_ptr : UniqPtr;

/**
 * Authors: initkfs
 */

import core.stdc.stdlib : malloc, realloc, free;

bool allocate(size_t sizeBytes, scope ref void[] ptr) @nogc nothrow @safe => allocateBytes(
    sizeBytes, ptr);
bool reallocate(size_t newBytes, scope ref void[] ptr) @nogc nothrow @safe => reallocateBytes(
    newBytes, ptr);
bool deallocate(scope void[] ptr) @nogc nothrow @safe => deallocateBytes(ptr);

protected
{
    bool allocateBytes(size_t sizeBytes, scope ref void[] ptr) @nogc nothrow @trusted
    {
        void* newPtr = malloc(sizeBytes);
        if (!newPtr)
        {
            return false;
        }
        ptr = newPtr[0 .. sizeBytes];
        return true;
    }

    bool reallocateBytes(size_t newBytes, scope ref void[] ptr) @nogc nothrow @trusted
    {
        void* newPtr = realloc(ptr.ptr, newBytes);
        if (!newPtr)
        {
            return false;
        }
        ptr = newPtr[0 .. newBytes];
        return true;
    }

    bool deallocateBytes(scope void[] ptr) @nogc nothrow @trusted
    {
        if (!ptr)
        {
            return false;
        }
        free(ptr.ptr);
        return true;
    }
}

version (D_BetterC)
{
}
else
{
    import api.core.mems.allocs.allocator : uniq, Allocator, AllocFuncType, FreeFuncType, ReallocFuncType;

    class Mallocator : Allocator
    {
        this() pure nothrow @safe
        {
            allocFunPtr = &allocate;
            reallocFunPtr = &reallocate;
            freeFunPtr = &deallocate;
        }
    }
}

unittest
{
    import MemAllocator = api.core.mems.allocs.allocator;

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
