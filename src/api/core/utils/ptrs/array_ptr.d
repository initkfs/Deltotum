/**
 * Authors: initkfs
 */
module api.core.utils.ptrs.array_ptr;

import api.core.util.allocs.allocator : FreeFuncType, ReallocFuncType;

mixin template ArrayPtr(
    T,
    AllocType = ubyte,
    FreeFunc = FreeFuncType!AllocType,
    ReallocFunc = ReallocFuncType!AllocType)
{

    T[] _ptr;
    bool isFreed;

    bool isAutoFree;

    FreeFunc freeFunPtr;
    ReallocFunc reallocFunPtr;

    void release() @nogc nothrow @safe
    {
        _ptr = null;
        isFreed = false;
        freeFunPtr = null;
        reallocFunPtr = null;
    }

    bool reallcap(size_t newCapacity) nothrow @safe
    in (_ptr)
    in (!isFreed)
    in (reallocFunPtr)
    {
        assert(newCapacity > 0);

        auto newSize = newCapacity * T.sizeof;
        assert((newSize / newCapacity) == T.sizeof, "Reallocation size overflow");

        return realloc(newSize);
    }

    bool realloc(size_t newSize) nothrow @safe
    in (_ptr)
    in (!isFreed)
    in (reallocFunPtr)
    {
        assert(newSize > 0);

        static if (AllocType.sizeof != 1)
        {
            newSize = newSize / AllocType.sizeof;
            assert(newSize > 0, "Reallocation native size is zero");
        }

        AllocType[] reallocPtr = cast(AllocType[]) _ptr;
        bool isRealloc = reallocFunPtr(newSize, reallocPtr);
        assert(isRealloc);
        _ptr = (() @trusted => cast(T[]) reallocPtr)();

        return true;
    }

    protected inout(T*) index(size_t i) @nogc nothrow inout return scope @safe
    in (_ptr)
    in (!isFreed)
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
    in (!isFreed)
    {
        return _ptr;
    }

    inout(T[]) ptrUnsafe() @nogc nothrow inout return scope
    in (_ptr)
    in (!isFreed)
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
    in (!isFreed)
    {
        return _ptr[i .. j];
    }

    size_t sizeBytes() const @nogc nothrow @safe
    {
        return _ptr.length * T.sizeof;
    }

    size_t capacity() const @nogc nothrow @safe
    {
        return _ptr.length;
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
