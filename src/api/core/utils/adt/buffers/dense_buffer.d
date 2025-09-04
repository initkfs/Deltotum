/**
 * Authors: initkfs
 */
module api.core.utils.adt.buffers.dense_buffer;

struct DenseBuffer(T, size_t Capacity = 256,
    bool isAppendable = true,
    bool isStatic = true)
{
    private
    {
        static if (isStatic)
        {
            T[Capacity] _buffer;
        }
        else
        {
            T[] _buffer;
        }

        size_t _length;
    }

    invariant
    {
        assert(_length <= _buffer.length, "Buffer invariant: length must be less or equal than buffer");
    }

    this(bool isFillInit) nothrow pure @safe
    {
        initialize(isFillInit);
    }

    this(T[] slice, bool isFillInit = false) nothrow pure @safe
    {
        assert(slice.length <= Capacity, "Buffer overflow");
        this(isFillInit);
        _length = slice.length;
        if (_length > 0)
        {
            _buffer[] = slice;
        }
    }

    alias slice this;

    void initialize(bool isFillInit = false) nothrow @safe
    {
        static if (!isStatic)
        {
            if (_buffer.length != Capacity)
            {
                _buffer = new T[](Capacity);
            }
        }

        if (isFillInit)
        {
            fillInit;
        }
    }

    void fillInit() @nogc nothrow @safe
    {
        static if (__traits(isFloating, T))
        {
            _buffer[] = 0;
        }
        else
        {
            _buffer[] = T.init;
        }
    }

    inout(T[]) raw() inout nothrow
    {
        return _buffer;
    }

    inout(T[]) slice() inout nothrow return scope @safe
    {
        return _buffer[0 .. _length];
    }

    inout(T[]) opSlice(size_t dim = 0)(size_t i, size_t j) inout nothrow return @safe
    {
        static assert(dim == 0, "Only 0 dimension supported");
        assert(i < j, "Start slice index must be less than end");
        static if (isAppendable)
        {
            assert(j <= _length, "End length index overflow");
        }
        else
        {
            assert(j <= Capacity, "End index capacity overflow");
        }

        return _buffer[i .. j];
    }

    inout(T[]) opSlice() inout nothrow return @safe
    {
        return slice;
    }

    inout(T*) opIndex(size_t i) inout return @safe
    {
        static if (isAppendable)
        {
            assert(i < _length, "Static buffer length index overflow");
        }
        else
        {
            assert(i < Capacity, "Static buffer capacity index overflow");
        }

        return &_buffer[i];
    }

    void opIndexAssign(T value, size_t i) @safe
    {
        static if (isAppendable)
        {
            assert(i < _length, "Static buffer length index overflow");
        }
        else
        {
            assert(i < Capacity, "Static buffer capacity index overflow");
        }

        _buffer[i] = value;
    }

    void opIndexAssign(T value, size_t i1, size_t i2) @safe
    {

        opSlice(i1, i2)[] = value;
    }

    //a[] = v
    void opIndexAssign(T value) @safe
    {
        opSlice[0 .. _length] = value;
    }

    //a[i .. j] = v
    void opIndexAssign(T value, T[] slice) @safe
    {
        slice[] = value;
    }

    size_t capacity() const @nogc nothrow pure @safe
    {
        return Capacity;
    }

    size_t length() const @nogc nothrow pure @safe
    {
        return _length;
    }

    static if (!isAppendable)
    {
        void length(size_t value) @nogc nothrow @safe
        {
            assert(value <= Capacity);
            _length = value;
        }
    }

    bool append(T value) @nogc nothrow @safe
    {
        if (_length >= Capacity)
        {
            return false;
        }
        _buffer[_length] = value;
        _length++;
        return true;
    }

    bool append(scope T[] value) @nogc nothrow @safe
    {
        //TODO overflow
        size_t newLength = _length + value.length;
        if (newLength >= Capacity)
        {
            return false;
        }
        size_t oldLength = _length;
        _length = newLength;
        opSlice(oldLength, newLength)[] = value;
        return true;
    }

    bool append(T[] value) @nogc nothrow @safe
    {
        //TODO overflow
        size_t newLength = _length + value.length;
        if (newLength >= Capacity)
        {
            return false;
        }
        size_t oldLength = _length;
        _length = newLength;
        opSlice(oldLength, newLength)[] = value;
        return true;
    }

    void opOpAssign(string op : "~")(T rhs)
    {
        append(rhs);
    }

    void opOpAssign(string op : "~")(scope const(T)[] rhs)
    {
        append(rhs);
    }

    bool reset() @nogc nothrow @safe
    {
        _length = 0;
        return true;
    }

    bool equals(scope const(T)[] other) @safe
    {
        if (other.length != _length)
        {
            return false;
        }

        for (size_t i = 0; i < _length; i++)
        {
            if (_buffer[i] != other[i])
            {
                return false;
            }
        }

        return true;
    }

    auto range() return scope @safe
    {
        static struct StaticBufferRange
        {
            private
            {
                T[] slice;
                size_t currentIndex;
                size_t capacity;
            }

            this(scope T[] buff) @nogc nothrow pure @safe
            {
                this.slice = buff;
                capacity = slice.length;
            }

            bool empty() const @nogc nothrow pure @safe
            {
                return currentIndex >= capacity;
            }

            inout(T) front() inout @nogc nothrow pure @safe
            {
                return slice[currentIndex];
            }

            void popFront() @nogc nothrow @safe
            {
                currentIndex++;
            }
        }

        return StaticBufferRange(slice);
    }

    version (BetterC)
    {
        //TODO betterC
    }
    else
    {
        string toString()
        {
            import std.format : format;

            return format("[%s: %s]", typeof(this).stringof, cast(const(char)[]) _buffer[0 .. _length]);
        }
    }
}

@safe unittest
{
    DenseBuffer!(char) buffer1;

    assert(buffer1.length == 0);
    buffer1 ~= 'h';
    assert(buffer1.length == 1);
    assert(buffer1[] == ['h']);

    enum str1 = "hello world";
    buffer1 ~= str1[1 .. $];
    assert(buffer1.length == str1.length);
    assert(buffer1[] == str1);

    size_t buffer1IterCount;

    foreach (i, ch; buffer1)
    {
        switch (i)
        {
            case 0:
                assert(ch == 'h');
                break;
            case 1:
                assert(ch == 'e');
                break;
            case 2:
                assert(ch == 'l');
                break;
            case 3:
                assert(ch == 'l');
                break;
            case 4:
                assert(ch == 'o');
                break;
            case 5:
                assert(ch == ' ');
                break;
            case 6:
                assert(ch == 'w');
                break;
            case 7:
                assert(ch == 'o');
                break;
            case 8:
                assert(ch == 'r');
                break;
            case 9:
                assert(ch == 'l');
                break;
            case 10:
                assert(ch == 'd');
                break;
            default:
                break;
        }
        buffer1IterCount++;
    }
    assert(buffer1IterCount == str1.length);
}

@safe unittest
{
    enum str1 = "hello world";
    DenseBuffer!(char) buffer;
    buffer ~= str1;
    assert(buffer[] == str1);
    buffer[0] = 'e';
    assert(buffer[] == "eello world");

    buffer[0 .. 3] = 'h';
    assert(buffer[] == "hhhlo world");

    buffer[0 .. 5][] = ['w', 'o', 'r', 'l', 'd'];
    assert(buffer[] == "world world");

    buffer[] = 'w';
    assert(buffer.length == str1.length);
    assert(buffer[] == "wwwwwwwwwww");

    buffer.reset;
    assert(buffer.length == 0);
    assert(buffer[] == []);

    buffer ~= 'd';
    assert(buffer.length == 1);
    assert(buffer[] == ['d']);
}
