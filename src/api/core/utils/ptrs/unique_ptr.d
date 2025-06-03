/**
 * Authors: initkfs
 */
module api.core.utils.ptrs.unique_ptr;

import api.core.util.allocs.allocator : FreeFuncType, ReallocFuncType;
import api.core.utils.ptrs.array_ptr : ArrayPtr;

struct UniqPtr(T, AllocType = ubyte,
    FreeFunc = FreeFuncType!AllocType,
    ReallocFunc = ReallocFuncType!AllocType
)
{
    mixin ArrayPtr!(T, AllocType, FreeFunc, ReallocFunc);

    private this(
        bool isAutoFree,
        FreeFunc newFreeFunPtr,
        ReallocFunc newReallocFunPtr
    ) @nogc nothrow pure @safe
    {
        this.isAutoFree = isAutoFree;

        freeFunPtr = newFreeFunPtr;
        reallocFunPtr = newReallocFunPtr;
    }

    this(T[] ptrs,
        bool isAutoFree = true,
        FreeFunc newFreeFunPtr = null,
        ReallocFunc newReallocFunPtr = null
    ) @nogc nothrow pure @safe
    {
        _ptr = ptrs;
        this(isAutoFree, newFreeFunPtr, newReallocFunPtr);
    }

    this(T* newPtr,
        size_t sizeBytes,
        bool isAutoFree = true,
        FreeFunc newFreeFunPtr = null,
        ReallocFunc newReallocFunPtr = null
    ) @nogc nothrow pure
    {
        assert(newPtr);

        assert(sizeBytes > 0);
        assert(sizeBytes >= T.sizeof);

        auto capacity = sizeBytes / T.sizeof;
        assert(capacity > 0);

        _ptr = newPtr[0 .. capacity];
        this(isAutoFree, newFreeFunPtr, newReallocFunPtr);
    }

    this(UniqPtr!(T, AllocType) rhs) @nogc nothrow @safe
    {
        assert(!rhs.isFreed);
        _ptr = rhs._ptr;
        isFreed = false;
        this(rhs.isAutoFree, rhs.freeFunPtr, reallocFunPtr);

        rhs._ptr = null;
        rhs.freeFunPtr = null;
        rhs.reallocFunPtr = null;
        //rhs destructor
        rhs.isAutoFree = false;
    }

    alias value this;

    //@disable this();
    @disable this(this);
    @disable this(ref return scope UniqPtr!(T, AllocType) rhs) nothrow pure
    {
    }

    ~this() nothrow scope @safe
    {
        if (isAutoFree)
        {
            free;
        }
    }

    void free() @nogc nothrow scope @safe
    in (_ptr)
    in (freeFunPtr)
    {
        assert(!isFreed, "Memory pointer has already been freed");
        AllocType[] nativePtr = cast(AllocType[]) _ptr;
        isFreed = freeFunPtr(nativePtr);
        assert(isFreed, "Memory pointer not deallocated correctly");

        release;
    }

    // a = v
    void opAssign(T v) @nogc nothrow @safe
    {
        value = v;
    }

    void opAssign(ref UniqPtr!(T, AllocType) newPtr) @nogc nothrow @safe
    {
        if (_ptr)
        {
            free;
        }

        _ptr = newPtr.ptrUnsafe;
        assert(_ptr);

        isFreed = false;
        freeFunPtr = newPtr.freeFunPtr;
        reallocFunPtr = newPtr.reallocFunPtr;

        newPtr.release;
    }
}

@safe unittest
{
    int value = 45;
    auto ptr = (() @trusted => UniqPtr!(int)(&value, value.sizeof, isAutoFree:
            false))();

    assert(!ptr.isFreed, "Pointer freed");
    assert(ptr.sizeBytes == value.sizeof, "Pointer invalid size");

    assert(ptr.value == value, "Pointer value incorrect");
    assert(ptr[0] == value, "Pointer first index incorrect");

    () @trusted { assert(ptr.ptr == (&value)[0 .. 1], "Invalid raw pointer"); }();

    enum newValue = 2324;
    ptr.value = newValue;
    assert(ptr.value == newValue, "Pointer invalid new value");

    int[2] arr = [54, 65];
    auto ptr2 = UniqPtr!(int)(arr[], isAutoFree:
        false);

    auto ptr2Slice = ptr2[0 .. 2];
    assert(ptr2Slice == arr);

    int[2] arrZero = [0, 0];
    ptr2[0 .. 2][] = 0;
    assert(ptr2[0 .. 2] == arrZero);

    int[2] arr3 = [43, 43];
    ptr2[0, 2] = 43;
    assert(ptr2[0 .. 2] == arr3);

    int[2] arr34 = [23, 34];
    ptr2[0, 2] = arr34[];
    assert(ptr2[0 .. 2] == arr34);

    size_t iters;
    foreach (v; ptr2.range)
    {
        switch (iters)
        {
            case 0:
                assert(v == 23);
                break;
            case 1:
                assert(v == 34);
                break;
            default:
                break;
        }
        iters++;
    }
    assert(iters == 2);

    version (D_TypeInfo)
    {
        import core.stdc.stdlib : malloc, realloc, free;

        static bool allocate(size_t capacity, ref int[] ptr)
        {
            return (() @trusted {
                auto sizeBytes = capacity * int.sizeof;
                void* newPtr = malloc(sizeBytes);
                if (!newPtr)
                {
                    return false;
                }
                ptr = cast(int[]) newPtr[0 .. sizeBytes];
                return true;
            })();
        }

        static bool reallocPtr(size_t newBytes, scope ref void[] ptr) @nogc nothrow @safe
        {
            return (() @trusted {
                void* newPtr = realloc(ptr.ptr, newBytes);
                assert(newPtr);
                ptr = newPtr[0 .. newBytes];
                return true;
            })();
        }

        static bool freePtr(scope void[] ptr) @nogc nothrow @safe
        {
            return (() @trusted { free(ptr.ptr); return true; })();
        }

        int[] value2;
        assert(allocate(1, value2));

        auto ptrV2 = UniqPtr!(int)(value2, isAutoFree:
            true, &freePtr, &reallocPtr);
        assert(ptrV2.reallcap(2));
        assert(ptrV2.capacity == 2);
        assert(
            ptrV2.sizeBytes == int.sizeof * 2);
        ptrV2[0] = 13;
        ptrV2[1] = 15;
        assert(ptrV2[0 .. 2] == [13, 15]);

        int[] value3;
        assert(allocate(1, value3));
        auto ptrV3 = UniqPtr!(int)(value3, isAutoFree:
            true, &freePtr, &reallocPtr);
        assert(ptrV3.realloc(int.sizeof * 3));
        assert(ptrV3.capacity == 3);
        assert(ptrV3.sizeBytes == int.sizeof * 3);

        class A
        {
            UniqPtr!int ptr;
        }

        auto aCl = new A;
        scope (exit)
        {
            aCl.ptr.free;
        }

        int[] aClValue;
        assert(allocate(1, aClValue));
        aCl.ptr = UniqPtr!(int)(aClValue, isAutoFree:
            false, &freePtr, &reallocPtr);
        aCl.ptr = 20;
        assert(aCl.ptr.value == 20);

        //Move
        int[] moveValue = [1];
        auto ptrSrc = UniqPtr!int(moveValue, isAutoFree:
            true);
        UniqPtr!int ptrDst = __rvalue(ptrSrc);
        ptrDst.isAutoFree = false;
        assert(ptrDst._ptr == moveValue);
        assert(!ptrDst.isFreed);
        assert(!ptrSrc._ptr);
        assert(!ptrSrc.isAutoFree);
    }

}
