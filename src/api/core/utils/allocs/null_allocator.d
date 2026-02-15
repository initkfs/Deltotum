module api.core.utils.allocs.null_allocator;

import api.core.utils.allocs.allocator : Allocator;

/**
 * Authors: initkfs
 */

bool null_allocate(size_t sizeBytes, scope ref ubyte[] ptr)  nothrow @safe => false;
bool null_reallocate(size_t newBytes, scope ref ubyte[] ptr)  nothrow @safe => false;
bool null_deallocate(scope ubyte[] ptr)  nothrow @safe => false;

version (D_BetterC)
{
}
else
{
    class NullAllocator : Allocator
    {
        this() pure nothrow @safe
        {
            allocFunPtr = &null_allocate;
            reallocFunPtr = &null_reallocate;
            freeFunPtr = &null_deallocate;
        }
    }
}
