module app.core.mem.mallocator;

import app.core.mem.unique_ptr : UniqPtr;

/**
 * Authors: initkfs
 */

import core.stdc.stdlib : malloc, realloc, free;

void[] allocate(size_t sizeBytes) @nogc nothrow @trusted
{
    void* newPtr = malloc(sizeBytes);
    assert(newPtr);
    return newPtr[0 .. sizeBytes];
}

bool reallocate(scope ref void[] ptr, size_t newBytes) @nogc nothrow @trusted
{
    void* newPtr = realloc(ptr.ptr, newBytes);
    assert(newPtr);
    ptr = newPtr[0 .. newBytes];
    return true;
}

static bool deallocate(scope void[] ptr) @nogc nothrow @trusted
{
    free(ptr.ptr);
    return true;
}

import app.core.mem.allocator : Allocator, AllocFuncType, FreeFuncType, ReallocFuncType;

class Mallocator : Allocator
{
    static this()
    {
        allocFunPtr = &allocate;
        reallocFunPtr = &reallocate;
        freeFunPtr = &deallocate;
    }
}

unittest
{
    auto mCl2 = new Mallocator;
    mCl2.allocFunPtr = &allocate;
    mCl2.reallocFunPtr = &reallocate;
    mCl2.freeFunPtr = &deallocate;

    auto intPtr2 = mCl2.uptr!int;
    intPtr2 = 5;
    assert(intPtr2.value);
}
