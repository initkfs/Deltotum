module api.core.mems.allocs.null_allocator;

import api.core.mems.allocs.allocator : Allocator;

/**
 * Authors: initkfs
 */

bool null_allocate(size_t sizeBytes, scope ref void[] ptr) @nogc nothrow @safe => false;
bool null_reallocate(size_t newBytes, scope ref void[] ptr) @nogc nothrow @safe => false;
bool null_deallocate(scope void[] ptr) @nogc nothrow @safe => false;

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

        override bool canAlloc() const nothrow pure @safe => true;
    }
}
