module api.core.utils.allocs.null_allocator;

import api.core.utils.allocs.allocator : Allocator;

/**
 * Authors: initkfs
 */

bool null_allocate(size_t sizeBytes, scope ref ubyte[] ptr)  nothrow @trusted => false;
bool null_align_allocate(size_t sizeBytes, scope ref ubyte[] ptr, ulong alignSize)  nothrow @trusted => false;
bool null_reallocate(size_t newBytes, scope ref ubyte[] ptr)  nothrow @trusted => false;
bool null_deallocate(scope ubyte[] ptr)  nothrow @trusted => false;

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
            allocAlignFunPtr = &null_align_allocate;
            reallocFunPtr = &null_reallocate;
            freeFunPtr = &null_deallocate;
        }
    }
}
