module api.core.utils.allocs.gc_allocator;

import api.core.utils.ptrs.unique_ptr : UniqPtr;

import api.core.util.allocs.allocator : Allocator;

/**
 * Authors: initkfs
 */

bool allocate(T)(size_t size, scope ref T[] ptr) nothrow @safe => allocateGc(
    size, ptr);
bool reallocate(T)(size_t newSize, scope ref T[] ptr) nothrow @safe => reallocateGc(
    newSize, ptr);
bool deallocate(T)(scope T[] ptr) @nogc nothrow @safe => deallocateGc(ptr);

protected
{
    bool allocateGc(T)(size_t size, scope ref T[] ptr) nothrow @safe
    {
        ptr = new T[](size);
        return true;
    }

    bool reallocateGc(T)(size_t newSize, scope ref T[] ptr) nothrow @trusted
    {
        if (ptr.length == newSize)
        {
            return false;
        }

        if (newSize < ptr.length)
        {
            ptr = ptr[0 .. newSize];
            return true;
        }

        auto newPtr = new T[](newSize);
        newPtr[0 .. ptr.length] = ptr;

        ptr = newPtr;
        return true;
    }

    bool deallocateGc(T)(scope T[] ptr) @nogc nothrow @trusted
    {
        import core.memory : GC;

        if (auto arrBlk = GC.addrOf(ptr.ptr))
        {
            GC.free(arrBlk);
            return true;
        }

        return false;
    }
}

class GcAllocator(T = ubyte) : Allocator!T
{
    this() pure nothrow @safe
    {
        allocFunPtr = &allocate!T;
        reallocFunPtr = &reallocate!T;
        freeFunPtr = &deallocate!T;
    }
}

unittest
{
    auto alloc = new GcAllocator!ubyte;

    ubyte[] ptr;
    assert(alloc.allocFunPtr(2, ptr));
    assert(ptr == [0, 0]);
    ptr[] = [1, 2];

    assert(alloc.reallocFunPtr(5, ptr));
    assert(ptr == [1, 2, 0, 0, 0]);

    assert(alloc.freeFunPtr(ptr));

    import core.memory : GC;

    assert(!GC.addrOf(cast(void*) ptr));
}

unittest
{
    struct Foo
    {
        int a;
    }

    auto alloc = new GcAllocator!(Foo);

    Foo[] ptr;
    assert(alloc.allocFunPtr(2, ptr));
    assert(ptr == [Foo(0), Foo(0)]);

    ptr = [Foo(1), Foo(2)];
    assert(alloc.reallocFunPtr(4, ptr));
    assert(ptr.length == 4);
    assert(ptr == [Foo(1), Foo(2), Foo(0), Foo(0)]);

    assert(alloc.freeFunPtr(ptr));

    import core.memory : GC;

    assert(!GC.addrOf(cast(void*) ptr));
}
