/**
 * Authors: initkfs
 */
module api.core.utils.ptrs.shared_ptr;

import api.core.utils.allocs.allocator : AllocFuncType, FreeFuncType, ReallocFuncType;
import api.core.utils.ptrs.array_ptr : ArrayPtr;

struct SharedPtr(T, AllocType = ubyte,
    FreeFunc = FreeFuncType!AllocType,
    AllocFunc = AllocFuncType!AllocType,
    ReallocFunc = ReallocFuncType!AllocType,
)
{
    size_t* countPtr;

    mixin ArrayPtr!(T, AllocType, FreeFunc, ReallocFunc);

    this(T[] ptrs,
        AllocFunc allocFunPtr,
        FreeFunc newFreeFunPtr = null,
        ReallocFunc newReallocFunPtr = null
    ) nothrow @safe
    {
        assert(allocFunPtr);

        _ptr = ptrs;
        freeFunPtr = newFreeFunPtr;
        reallocFunPtr = newReallocFunPtr;

        size_t allocSize = size_t.sizeof / AllocType.sizeof;
        assert(allocSize > 0);
        AllocType[] allocArr;
        bool isAlloc = allocFunPtr(allocSize, allocArr);
        assert(isAlloc);
        countPtr = &(cast(size_t[]) allocArr)[0];

        inc;
    }

    alias value this;

    //@disable this();
    //@disable this(this);

    this(ref return scope SharedPtr!(T, AllocType) other) nothrow
    {
        _ptr = other.ptr;
        countPtr = other.countPtr;
        freeFunPtr = other.freeFunPtr;
        reallocFunPtr = other.reallocFunPtr;
        isFreed = other.isFreed;
        if (countPtr)
        {
            inc;
        }
    }

    ~this() nothrow scope
    {
        dec;
    }

    void free()  nothrow scope @trusted
    in (_ptr)
    in (freeFunPtr)
    {
        assert(!isFreed, "Memory pointer has already been freed");
        AllocType[] nativePtr = cast(AllocType[]) _ptr;
        isFreed = freeFunPtr(nativePtr);
        assert(isFreed, "Memory pointer not deallocated correctly");

        if (countPtr)
        {
            isFreed = freeFunPtr(cast(AllocType[]) countPtr[0..1]);
            assert(isFreed, "Shared counter not deallocated correctly");
            countPtr = null;
        }

        release;
    }

    // a = v
    void opAssign(T v)  nothrow @safe
    {
        value = v;
    }

    void opAssign(ref SharedPtr!(T, AllocType) other)  nothrow @safe
    {
        if (this is other)
        {
            return;
        }

        if (other.countPtr)
        {
            other.inc;
        }

        dec;

        _ptr = other.ptr;
        countPtr = other.countPtr;
        freeFunPtr = other.freeFunPtr;
        reallocFunPtr = other.reallocFunPtr;
        isFreed = other.isFreed;
    }

    bool inc()  nothrow pure @safe
    {
        if (!countPtr)
        {
            return false;
        }

        if (*countPtr == countPtr.max)
        {
            return false;
        }

        (*countPtr)++;
        return true;
    }

    bool dec()  nothrow @safe
    {
        if (!countPtr || *countPtr == 0)
        {
            return false;
        }

        (*countPtr)--;
        if (*countPtr == 0 && !isFreed)
        {
            free;
        }
        return true;
    }

    size_t count() const nothrow  pure @safe => countPtr ? *countPtr : 0;
}

unittest
{
    static bool isFree;

    static bool alloc(size_t size, scope ref ubyte[] ptr) nothrow @safe
    {
        ptr = new ubyte[size];
        return true;
    }

    static bool realloc(size_t newSize, scope ref ubyte[] ptr) nothrow @trusted
    {
        return true;
    }

    static bool free(scope ubyte[] ptr)  nothrow @safe
    {
        return isFree = true;
    }

    ubyte[] arr = [1, 2, 3];

    SharedPtr!ubyte ptr1;

    {
        ptr1 = SharedPtr!ubyte(arr, &alloc, &free, &realloc);
        assert(ptr1.count == 1);
        assert(!isFree);

        ptr1 = ptr1;
        assert(ptr1.count == 1);

        {
            //copy
            auto ptr2 = ptr1;
            assert(ptr1.count == 2);
            assert(ptr2.count == 2);
            assert(!isFree);

            //TODO
            //ptr2 = ptr1;
            //ptr1 = ptr2; 

            //assign
            {
                auto ptr3 = SharedPtr!ubyte(arr, &alloc, &free, &realloc);
                assert(ptr3.count == 1);
                ptr3 = ptr2;
                assert(ptr3.count == 3);
                assert(ptr2.count == 3);
            }
            assert(isFree);
            isFree = false;
        }

        assert(ptr1.count == 1);
        assert(!isFree);
    }

    ptr1.dec;
    assert(ptr1.count == 0);
    assert(isFree);
    isFree = false;
}
