module api.core.utils.allocs.mallocator;

/**
 * Authors: initkfs
 */

import core.stdc.stdlib : malloc, realloc, free;

bool allocate(size_t size, scope ref ubyte[] ptr) nothrow @trusted
{
    if (size == 0)
    {
        return true;
    }

    ubyte* newPtr = cast(ubyte*) malloc(size);
    if (!newPtr)
    {
        return false;
    }
    ptr = newPtr[0 .. size];
    return true;
}

bool reallocate(size_t newSize, scope ref ubyte[] ptr) nothrow @trusted
{
    if (!ptr.ptr)
    {
        return allocate(newSize, ptr);
    }
    else
    {
        if (newSize == 0)
        {
            return deallocate(ptr);
        }
    }

    ubyte* newPtr = cast(ubyte*) realloc(ptr.ptr, newSize);
    if (!newPtr)
    {
        return false;
    }
    ptr = newPtr[0 .. newSize];
    return true;
}

bool deallocate(scope ubyte[] ptr) nothrow @trusted
{
    if (!ptr.ptr)
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
    version (D_BetterC)
    {

    }
    else
    {
        auto alloc = new Mallocator;

        int[] intPtr1 = alloc.array!int(5);
        assert(intPtr1.length == 5);
        intPtr1[] = [1, 2, 3, 4, 5];
        assert(intPtr1 == [1, 2, 3, 4, 5]);

        int[] intPtr2 = alloc.realloc(10, intPtr1);
        assert(intPtr2.length == 10);

        intPtr2[5 .. $] = [6, 7, 8, 9, 10];
        assert(intPtr2 == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);

        assert(alloc.free(intPtr2));
    }
}
