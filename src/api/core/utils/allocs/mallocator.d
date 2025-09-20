module api.core.utils.allocs.mallocator;

import api.core.utils.ptrs.unique_ptr : UniqPtr;

/**
 * Authors: initkfs
 */

import core.stdc.stdlib : malloc, realloc, free;

bool allocateBytes(T)(size_t size, scope ref T[] ptr)  nothrow @trusted
{
    void* newPtr = malloc(size * T.sizeof);
    if (!newPtr)
    {
        return false;
    }
    ptr = (cast(T*) newPtr)[0 .. size];
    return true;
}

bool reallocateBytes(T)(size_t newSize, scope ref T[] ptr)  nothrow @trusted
{
    const newSizeBytes = newSize * T.sizeof;
    void* newPtr = realloc(ptr.ptr, newSizeBytes);
    if (!newPtr)
    {
        return false;
    }
    ptr = (cast(T*) newPtr)[0 .. newSize];
    return true;
}

bool deallocateBytes(T)(scope T[] ptr)  nothrow @trusted
{
    if (!ptr)
    {
        return false;
    }
    free(ptr.ptr);
    return true;
}

version (D_BetterC)
{
}
else
{
    import api.core.utils.allocs.allocator : Allocator;

    class Mallocator : Allocator!ubyte
    {
        this() pure nothrow @safe
        {
            allocFunPtr = &allocateBytes!ubyte;
            reallocFunPtr = &reallocateBytes!ubyte;
            freeFunPtr = &deallocateBytes!ubyte;
        }
    }
}

unittest
{
    version (D_BetterC)
    {
        import MemAllocator = api.core.utils.allocs.allocator;

        MemAllocator.allocFunPtr = &allocate;
        MemAllocator.reallocFunPtr = &reallocate;
        MemAllocator.freeFunPtr = &deallocate;

        UniqPtr!int intPtr1 = MemAllocator.uniqptr!int;
        intPtr1 = 5;
        assert(intPtr1.value == 5);
    }
    else
    {
        auto mCl2 = new Mallocator;
        auto intPtr2 = mCl2.uniqptr!int;
        intPtr2 = 5;
        assert(intPtr2.value);
    }
}
