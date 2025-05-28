module api.util.allocs.mallocator;

import api.util.ptrs.unique_ptr : UniqPtr;

/**
 * Authors: initkfs
 */

import core.stdc.stdlib : malloc, realloc, free;

bool allocate(T)(size_t sizeBytes, scope ref T[] ptr) @nogc nothrow @safe => allocateBytes(
    sizeBytes, ptr);
bool reallocate(T)(size_t newBytes, scope ref T[] ptr) @nogc nothrow @safe => reallocateBytes(
    newBytes, ptr);
bool deallocate(T)(scope T[] ptr) @nogc nothrow @safe => deallocateBytes(ptr);

protected
{
    bool allocateBytes(T)(size_t size, scope ref T[] ptr) @nogc nothrow @trusted
    {
        void* newPtr = malloc(size * T.sizeof);
        if (!newPtr)
        {
            return false;
        }
        ptr = (cast(T*)newPtr)[0 .. size];
        return true;
    }

    bool reallocateBytes(T)(size_t newSize, scope ref T[] ptr) @nogc nothrow @trusted
    {
        const newSizeBytes = newSize * T.sizeof;
        void* newPtr = realloc(ptr.ptr, newSizeBytes);
        if (!newPtr)
        {
            return false;
        }
        ptr = (cast(T*)newPtr)[0 .. newSize];
        return true;
    }

    bool deallocateBytes(T)(scope T[] ptr) @nogc nothrow @trusted
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
    import api.util.allocs.allocator : Allocator;

    class Mallocator : Allocator!ubyte
    {
        this() pure nothrow @safe
        {
            allocFunPtr = &allocate!ubyte;
            reallocFunPtr = &reallocate!ubyte;
            freeFunPtr = &deallocate!ubyte;
        }
    }
}

unittest
{
    import MemAllocator = api.util.allocs.allocator;

    version (D_BetterC)
    {
        MemAllocator.allocFunPtr = &allocate;
        MemAllocator.reallocFunPtr = &reallocate;
        MemAllocator.freeFunPtr = &deallocate;

        UniqPtr!int intPtr1 = MemAllocator.uniq!int;
        intPtr1 = 5;
        assert(intPtr1.value == 5);
    }
    else
    {
        auto mCl2 = new Mallocator;
        auto intPtr2 = mCl2.uniq!int;
        intPtr2 = 5;
        assert(intPtr2.value);
    }
}
