/**
 * Authors: initkfs
 */
module api.core.utils.ptrs.shared_ptr;

import api.util.allocs.allocator : FreeFuncType, ReallocFuncType;

struct SharedPtr(T, AllocType = ubyte,
    FreeFunc = FreeFuncType!AllocType,
    AllocFunc = AllocFuncType!AllocType,
    ReallocFunc = ReallocFuncType!AllocType,
)
{
    //private
    //{
    T[] _ptr;
    bool _freed;

    FreeFunc _freeFunPtr;
    ReallocFunc _reallocFunPtr;

    size_t* _count;
    //}

    this(T[] ptrs,
        FreeFunc newFreeFunPtr = null,
        AllocFunc allocFunPtr = null,
        ReallocFunc newReallocFunPtr = null
    ) nothrow pure @safe
    {
        _ptr = ptrs;
        _freeFunPtr = newFreeFunPtr;
        _reallocFunPtr = newReallocFunPtr;

        if (!_count)
        {
            if (!allocFunPtr)
            {
                _count = new size_t;
            }
            else
            {
                size_t allocSize = size_t.sizeof / AllocType.sizeof;
                assert(allocSize > 0);
                AllocType[] allocArr;
                bool isAlloc = _reallocFunPtr(allocSize, allocArr);
                assert(isAlloc);
                _count = (cast(size_t[]) allocArr).ptr;
            }

            assert(_count);
        }

        inc;
    }

    alias value this;

    this(ref return scope SharedPtr!(T, AllocType) other) nothrow
    {
        _ptr = other.ptr;
        _count = other._count;
        _freeFunPtr = other._freeFunPtr;
        _reallocFunPtr = other._reallocFunPtr;
        _freed = other._freed;
        if (_count)
        {
            inc;
        }
    }

    ~this() nothrow scope @safe
    {
        dec;
    }

    void opAssign(ref SharedPtr!(T, AllocType) other) @nogc nothrow @safe
    {
        if (this is other)
        {
            return;
        }

        if (other._count)
        {
            other.inc;
        }

        dec;

        _ptr = other.ptr;
        _count = other._count;
        _freeFunPtr = other._freeFunPtr;
        _reallocFunPtr = other._reallocFunPtr;
        _freed = other._freed;
    }

    bool inc() @nogc nothrow pure @safe
    {
        if (!_count)
        {
            return false;
        }

        if (*_count == _count.max)
        {
            return false;
        }

        (*_count)++;
        return true;
    }

    bool dec() @nogc nothrow @safe
    {
        if (!count || *_count == 0)
        {
            return false;
        }

        (*_count)--;
        if (*_count == 0 && !_freed)
        {
            free;
        }
        return true;
    }

    bool isFreed() const @nogc nothrow pure @safe
    {
        return _freed;
    }

    void free() @nogc nothrow scope @safe
    in (_ptr)
    in (_freeFunPtr)
    {
        assert(_count && *_count == 0, "Counter not zero");

        assert(!_freed, "Memory pointer has already been freed");
        AllocType[] nativePtr = cast(AllocType[]) _ptr;
        bool isFreed = _freeFunPtr(nativePtr);
        assert(isFreed, "Memory pointer not deallocated correctly");

        _ptr = null;
        _freed = true;
    }

    void release() @nogc nothrow @safe
    in (!_freed)
    {
        _ptr = null;
        _freed = false;
    }

    bool reallcap(size_t newCapacity) nothrow @safe
    in (_ptr)
    in (!_freed)
    in (_reallocFunPtr)
    {
        assert(newCapacity > 0);

        auto newSize = newCapacity * T.sizeof;
        assert((newSize / newCapacity) == T.sizeof, "Reallocation size overflow");

        return realloc(newSize);
    }

    bool realloc(size_t newSize) nothrow @safe
    in (_ptr)
    in (!_freed)
    in (_reallocFunPtr)
    {
        assert(newSize > 0);

        size_t newNativeSize = newSize / AllocType.sizeof;
        assert(newNativeSize > 0, "Reallocation native size is zero");

        AllocType[] reallocPtr = cast(AllocType[]) _ptr;
        bool isRealloc = _reallocFunPtr(newNativeSize, reallocPtr);
        assert(isRealloc);
        _ptr = (() @trusted => cast(T[]) reallocPtr)();

        return true;
    }

    protected inout(T*) index(size_t i) @nogc nothrow inout return scope @safe
    in (_ptr)
    in (!_freed)
    {
        return &_ptr[i];
    }

    inout(T) opIndex(size_t i) @nogc nothrow inout @safe
    {
        return *(index(i));
    }

    inout(T) value() @nogc nothrow inout @safe
    {
        return opIndex(0);
    }

    void value(T newValue) @nogc nothrow @safe
    {
        *index(0) = newValue;
    }

    inout(T[]) ptr() @nogc nothrow inout return scope @safe
    in (_ptr)
    in (!_freed)
    {
        return _ptr;
    }

    inout(T[]) ptrUnsafe() @nogc nothrow inout return scope
    in (_ptr)
    in (!_freed)
    {
        return _ptr;
    }

    // a[i] = v
    void opIndexAssign(T value, size_t i) @nogc nothrow @safe
    {
        *(index(i)) = value;
    }

    // a[i1, i2] = v
    void opIndexAssign(T value, size_t i1, size_t i2) @nogc nothrow @safe
    {
        opSlice(i1, i2)[] = value;
    }

    void opIndexAssign(T[] value, size_t i1, size_t i2) @nogc nothrow @safe
    {
        opSlice(i1, i2)[] = value;
    }

    inout(T[]) opSlice(size_t i, size_t j) @nogc nothrow inout return scope @safe
    in (_ptr)
    in (!_freed)
    {
        return _ptr[i .. j];
    }

    void opAssign(T newVal) @nogc nothrow @safe
    {
        this.value(newVal);
    }

    size_t count() const @nogc nothrow @safe => _count ? *_count : 0;

    size_t sizeBytes() const @nogc nothrow @safe
    {
        return _ptr.length * T.sizeof;
    }

    size_t capacity() const @nogc nothrow @safe
    {
        return _ptr.length;
    }

    FreeFunc freeFunPtr() const @nogc nothrow @safe
    in (_freeFunPtr)
    {
        return _freeFunPtr;
    }

    ReallocFunc reallocFunPtr() const @nogc nothrow @safe
    in (_reallocFunPtr)
    {
        return _reallocFunPtr;
    }

    auto range() @nogc nothrow return scope @safe
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

unittest
{
    static bool isFree;

    static bool alloc(size_t size, scope ref ubyte[] ptr) nothrow @safe {
        ptr = new ubyte[size];
        return true;
    }

    static bool realloc(size_t newSize, scope ref ubyte[] ptr) nothrow @trusted
    {
        return true;
    }

    static bool free(scope ubyte[] ptr) @nogc nothrow @safe
    {
        return isFree = true;
    }

    ubyte[] arr = [1, 2, 3];

    SharedPtr!ubyte ptr1;

    {
        ptr1 = SharedPtr!ubyte(arr, &free, &alloc, &realloc);
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
                auto ptr3 = SharedPtr!ubyte(arr, &deallocateBytes, &reallocateBytes);
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
