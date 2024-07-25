/**
 * Authors: initkfs
 */
module app.core.mem.unique_ptr;

import app.core.mem.allocator : FreeFuncType, ReallocFuncType;

struct UniqPtr(T,
    FreeFunc = FreeFuncType,
    ReallocFunc = ReallocFuncType
)
{
    private
    {
        T[] _ptr;
        bool _freed;
        FreeFunc _freeFunPtr;
        ReallocFunc _reallocFunPtr;
    }

    bool isAutoFree;

    private this(
        bool isAutoFree,
        FreeFunc newFreeFunPtr,
        ReallocFunc newReallocFunPtr
    ) @nogc nothrow pure @safe
    {
        this.isAutoFree = isAutoFree;

        _freeFunPtr = newFreeFunPtr;
        _reallocFunPtr = newReallocFunPtr;
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

    alias value this;

@nogc nothrow:

    @disable this(ref return scope UniqPtr!T rhs) pure
    {
    }

    ~this() @safe
    {
        if (isAutoFree)
        {
            free;
        }
    }

    bool isFreed() const pure @safe
    {
        return _freed;
    }

    void free() @safe
    in (_ptr)
    in (_freeFunPtr)
    {
        assert(!_freed, "Memory pointer has already been freed");

        bool isFreed = _freeFunPtr(_ptr);
        assert(isFreed, "Memory pointer not deallocated correctly");

        _ptr = null;
        _freed = true;
    }

    void release() @safe
    in (!_freed)
    {
        _ptr = null;
        _freed = false;
    }

    bool reallcap(size_t newCapacity) @safe
    in (_ptr)
    in (!_freed)
    in (_reallocFunPtr)
    {
        assert(newCapacity > 0);

        auto newSize = newCapacity * T.sizeof;
        assert((newSize / newCapacity) == T.sizeof, "Reallocation size overflow");

        return realloc(newSize);
    }

    bool realloc(size_t newSizeBytes) @trusted
    in (_ptr)
    in (!_freed)
    in (_reallocFunPtr)
    {
        assert(newSizeBytes > 0);

        void[] reallocPtr = _ptr;
        bool isRealloc = _reallocFunPtr(reallocPtr, newSizeBytes);
        assert(isRealloc);
        _ptr = cast(T[]) reallocPtr;

        return true;
    }

    protected inout(T*) index(size_t i) inout return @safe
    in (_ptr)
    in (!_freed)
    {
        return &_ptr[i];
    }

    inout(T) opIndex(size_t i) inout @safe
    {
        return *(index(i));
    }

    inout(T) value() inout @safe
    {
        return opIndex(0);
    }

    void value(T newValue) @safe
    {
        *index(0) = newValue;
    }

    inout(T[]) ptr() inout return @safe
    in (_ptr)
    in (!_freed)
    {
        return _ptr;
    }

    inout(T[]) ptrUnsafe() inout
    in (_ptr)
    in (!_freed)
    {
        return _ptr;
    }

    // a[i] = v
    void opIndexAssign(T value, size_t i) @safe
    {
        *(index(i)) = value;
    }

    // a[i1, i2] = v
    void opIndexAssign(T value, size_t i1, size_t i2) @safe
    {
        opSlice(i1, i2)[] = value;
    }

    void opIndexAssign(T[] value, size_t i1, size_t i2) @safe
    {
        opSlice(i1, i2)[] = value;
    }

    inout(T[]) opSlice(size_t i, size_t j) inout return @safe
    in (_ptr)
    in (!_freed)
    {
        return _ptr[i .. j];
    }

    void opAssign(T newVal) @safe
    {
        this.value(newVal);
    }

    void opAssign(UniqPtr!T newPtr) @safe
    {
        if (_ptr)
        {
            free;
        }

        _freed = false;

        _ptr = newPtr.ptrUnsafe;
        assert(_ptr);

        _freeFunPtr = newPtr.freeFunPtr;
        _reallocFunPtr = newPtr.reallocFunPtr;

        //newPtr.release;
    }

    size_t sizeBytes() const @safe
    {
        return _ptr.length * T.sizeof;
    }

    size_t capacity() const @safe
    {
        return _ptr.length;
    }

    FreeFunc freeFunPtr() const @safe
    in (_freeFunPtr)
    {
        return _freeFunPtr;
    }

    ReallocFunc reallocFunPtr() const @safe
    in (_reallocFunPtr)
    {
        return _reallocFunPtr;
    }

    auto range() return scope @safe
    {
        static struct PtrRange
        {
            private
            {
                T[] ptr;
                size_t currentIndex;
            }

            this(T[] newPtr)
            {
                this.ptr = newPtr;
            }

            bool empty() const
            {
                return currentIndex >= ptr.length;
            }

            inout(T) front() inout
            {
                return ptr[currentIndex];
            }

            void popFront()
            {
                currentIndex++;
            }
        }

        return PtrRange(_ptr);
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

        static int[] allocate(size_t capacity = 1) @nogc nothrow @trusted
        {
            auto sizeBytes = capacity * int.sizeof;
            void* newPtr = malloc(sizeBytes);
            assert(newPtr);
            return cast(int[]) newPtr[0 .. sizeBytes];
        }

        static bool reallocPtr(scope ref void[] ptr, size_t newBytes) @nogc nothrow @trusted
        {
            void* newPtr = realloc(ptr.ptr, newBytes);
            assert(newPtr);
            ptr = newPtr[0 .. newBytes];
            return true;
        }

        static bool freePtr(scope void[] ptr) @nogc nothrow @trusted
        {
            free(ptr.ptr);
            return true;
        }

        int[] value2 = allocate;
        auto ptrV2 = UniqPtr!(int)(value2, isAutoFree:
            true, &freePtr, &reallocPtr);
        assert(ptrV2.reallcap(2));
        assert(ptrV2.capacity == 2);
        assert(
            ptrV2.sizeBytes == int.sizeof * 2);
        ptrV2[0] = 13;
        ptrV2[1] = 15;
        assert(ptrV2[0 .. 2] == [13, 15]);

        int[] value3 = allocate;
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

        int[] aClValue = allocate;
        aCl.ptr = UniqPtr!(int)(aClValue, isAutoFree:
            false, &freePtr, &reallocPtr);
        aCl.ptr = 20;
        assert(aCl.ptr.value == 20);
    }

}
