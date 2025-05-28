module api.util.allocs.null_allocator;

import api.util.allocs.allocator : Allocator;

/**
 * Authors: initkfs
 */

bool null_allocate(size_t sizeBytes, scope ref ubyte[] ptr) @nogc nothrow @safe => false;
bool null_reallocate(size_t newBytes, scope ref ubyte[] ptr) @nogc nothrow @safe => false;
bool null_deallocate(scope ubyte[] ptr) @nogc nothrow @safe => false;

version (D_BetterC)
{
}
else
{
    class NullAllocator : Allocator!ubyte
    {
        this() pure nothrow @safe
        {
            allocFunPtr = &null_allocate;
            reallocFunPtr = &null_reallocate;
            freeFunPtr = &null_deallocate;
        }
    }
}
