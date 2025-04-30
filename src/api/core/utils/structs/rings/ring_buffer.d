module api.core.utils.structs.rings.ring_buffer;

import api.core.utils.structs.container_result : ContainerResult;

import core.sync.mutex : Mutex;

//import core.atomic;

/**
 * Authors: initkfs
 */
struct RingBuffer(BufferType, size_t BufferSize, bool isWithMutex = true, bool isStaticArray = false)
{
    bool isWriteForFill;

    private
    {
        static if (isStaticArray)
        {
            BufferType[BufferSize] _buffer;
        }
        else
        {
            BufferType[] _buffer;
        }

        size_t _readIndex; //remove
        size_t _writeIndex; //add
        size_t _size;

        bool _lock;
    }

    static if (isWithMutex)
    {
        shared Mutex mutex;

        this(shared Mutex m) pure @safe nothrow
        {
            assert(m);
            mutex = m;
            initialize;
        }
    }

    bool initialize() pure @safe nothrow
    {
        static if (!isStaticArray)
        {
            if (_buffer.length == BufferSize)
            {
                return false;
            }

            _buffer = new BufferType[](BufferSize);
        }

        fillInit;

        return true;
    }

    void fillInit() @nogc nothrow @safe
    {
        static if (__traits(isFloating, BufferType))
        {
            _buffer[] = 0;
        }
        else
        {
            _buffer[] = BufferType.init;
        }
    }

    const @nogc nothrow @safe
    {
        bool isEmpty() => _size == 0;
        bool isFull() => _size >= BufferSize;
        bool isLocked() => _lock;

        size_t writeIndex() => _writeIndex;
        size_t readIndex() => _readIndex;
        size_t size() => _size;
        size_t sizeLimit() => BufferSize;

        size_t capacity()
        {
            assert(BufferSize >= size);
            return BufferSize - _size;
        }
    }

    @nogc nothrow @safe
    {
        void lock()
        {
            _lock = true;
        }

        void unlock()
        {
            _lock = false;
        }
    }

    static if (isWithMutex)
    {
        @nogc @safe
        {
            void lockSync()
            {
                synchronized (mutex)
                {
                    lock;
                }
            }

            void unlockSync()
            {
                synchronized (mutex)
                {
                    unlock;
                }
            }

            bool isLockedSync()
            {
                synchronized (mutex)
                {
                    return isLocked;
                }
            }
        }

        ContainerResult writeSync(BufferType[] items) @nogc @safe
        {
            synchronized (mutex)
            {
                return write(items);
            }
        }

        ContainerResult writeIfNoLockedSync(BufferType[] items) @nogc @safe
        {
            synchronized (mutex)
            {
                if (_lock)
                {
                    return ContainerResult.success;
                }

                return write(items);
            }
        }

        ContainerResult readIfNoLockedSync(BufferType[] elements, size_t count) @safe
        {
            synchronized (mutex)
            {
                if (_lock)
                {
                    return ContainerResult.success;
                }

                return read(elements, count);
            }
        }

        ContainerResult readSync(scope void delegate(BufferType[], BufferType[]) @nogc @safe onBuffer, size_t count) @nogc @safe
        {
            synchronized (mutex)
            {
                return read(onBuffer, count);
            }
        }

        ContainerResult readSync(BufferType[] elements, size_t count) @safe
        {
            synchronized (mutex)
            {
                return read(elements, count);
            }
        }

        ContainerResult readSync(out BufferType value)
        {
            synchronized (mutex)
            {
                return read(value);
            }
        }
    }

    // bool isIndexOverlap(size_t index)
    // {
    //     if(_readIndex <= _writeIndex){

    //     }
    //     if(_readIndex > 0 && _writeIndex <= _readIndex && index > _readIndex){
    //         return true;
    //     }

    //     return false;
    // }

    ContainerResult write(BufferType[] items) nothrow @safe
    {
        if (_lock)
        {
            return ContainerResult.locked;
        }

        size_t itemsLen = items.length;

        if (itemsLen == 0)
        {
            return ContainerResult.noitems;
        }

        if (isFull)
        {
            return ContainerResult.full;
        }

        if (itemsLen > capacity)
        {
            if (!isWriteForFill || capacity == 0)
            {
                return ContainerResult.noenoughspace;
            }

            itemsLen = capacity;
            items = items[0..itemsLen];
        }

        size_t rest = _writeIndex == 0 ? BufferSize : BufferSize - _writeIndex;

        size_t buffLen = itemsLen;

        if (buffLen <= rest)
        {
            size_t endIndex = _writeIndex + buffLen;

            _buffer[writeIndex .. endIndex] = items;

            _writeIndex = endIndex;

            if (_writeIndex >= BufferSize)
            {
                _writeIndex = 0;
            }
            //atomicOp!"+="(_size, buffLen);
            _size += buffLen;

            //import std;
            //debug stderr.writefln("Write %s, ri %s, end %s, size %s", buffLen, _writeIndex, endIndex, size);

            return ContainerResult.success;
        }

        size_t lastElems = rest;
        size_t remainElems = buffLen - lastElems;

        size_t endIndex = _writeIndex + lastElems;

        _buffer[writeIndex .. endIndex] = items[0 .. lastElems];
        _buffer[0 .. remainElems] = items[lastElems .. $];

        _writeIndex = remainElems;
        if (_writeIndex >= BufferSize)
        {
            _writeIndex = 0;
        }
        //atomicOp!"+="(_size, buffLen);
        _size += buffLen;

        //import std;
        //debug stderr.writefln("Write rest %s, ri %s, end %s, size %s", buffLen, _writeIndex, endIndex, size);

        return ContainerResult.success;
    }

    ContainerResult read(scope BufferType[] elements, size_t count) @nogc @safe
    {
        return read((buff, rest) {

            size_t index;

            elements[0 .. buff.length] = buff;
            index += buff.length;

            if (rest.length == 0)
            {
                elements[index .. (index + rest.length)] = rest;
            }
        }, count);
    }

    ContainerResult read(scope void delegate(BufferType[], BufferType[]) @nogc @safe onElementsRest, size_t count) @nogc @safe
    {
        if (_lock)
        {
            return ContainerResult.locked;
        }

        if (isEmpty)
        {
            return ContainerResult.empty;
        }

        if (count > _size)
        {
            return ContainerResult.nofilled;
        }

        size_t endIndex = _readIndex + count;

        size_t rest;

        if (endIndex > BufferSize)
        {
            endIndex = BufferSize;

            const endSliceCapacity = endIndex - _readIndex;
            assert(count > endSliceCapacity);
            rest = count - endSliceCapacity;
        }

        BufferType[] endSlice = _buffer[_readIndex .. endIndex];

        _readIndex = endIndex;
        if (_readIndex >= BufferSize)
        {
            _readIndex = 0;
        }

        BufferType[] startSlice;
        if (rest > 0)
        {
            startSlice = _buffer[0 .. rest];
            _readIndex = rest;
        }

        onElementsRest(endSlice, startSlice);

        //atomicOp!"-="(_size, count);
        _size -= count;

        //import std;
        //debug stderr.writefln("Read %s, ri %s, end %s, size %s", count, _readIndex, endIndex, size);

        return ContainerResult.success;
    }

    ContainerResult read(out BufferType value)
    {
        if (_lock)
        {
            return ContainerResult.locked;
        }

        if (isEmpty)
        {
            return ContainerResult.empty;
        }

        value = _buffer[_readIndex];

        _readIndex++;
        if (_readIndex >= BufferSize)
        {
            _readIndex = 0;
        }

        assert(_size > 0);
        _size--;

        return ContainerResult.success;
    }

    void reset() @nogc nothrow @safe
    {
        _writeIndex = 0;
        _readIndex = 0;
        _size = 0;
        fillInit;
    }

    void onItem(scope bool delegate(BufferType) onItemIsContinue)
    {
        foreach (i; 0 .. _size)
        {
            size_t index = (_readIndex + i) % BufferSize;
            if (!onItemIsContinue(_buffer[index]))
            {
                break;
            }
        }
    }

    inout(BufferType[]) buffer() return inout => _buffer;
}

@safe unittest
{
    auto buff = RingBuffer!(int, 5, false).init;
    buff.initialize;

    assert(buff.write([1, 2, 3]));
    assert(buff.size == 3);
    assert(buff.writeIndex == 3);
    assert(buff.buffer == [1, 2, 3, 0, 0]);

    buff.reset;
    assert(buff.size == 0);
    assert(buff.writeIndex == 0);
    assert(buff.buffer == [0, 0, 0, 0, 0]);

    assert(buff.write([1, 2, 3]));

    int[5] elems = 0;
    assert(buff.read(elems[], 1));
    assert(buff.readIndex == 1);
    assert(buff.writeIndex == 3);
    assert(buff.size == 2);
    assert(buff.buffer == [1, 2, 3, 0, 0]);
    assert(elems == [1, 0, 0, 0, 0]);

    assert(buff.read(elems[], 2));
    assert(buff.readIndex == 3);
    assert(buff.size == 0);
    assert(buff.buffer == [1, 2, 3, 0, 0]);
    assert(elems == [2, 3, 0, 0, 0]);
}

@safe unittest
{
    auto buff = RingBuffer!(int, 5, false).init;
    buff.initialize;

    assert(buff.write([1, 2, 3, 4, 5]));
    assert(buff.isFull);

    int[] elems = new int[](5);
    assert(buff.read(elems, 5));
    assert(elems == [1, 2, 3, 4, 5]);
    assert(buff.size == 0);
    assert(buff.readIndex == 0);
    assert(buff.writeIndex == 0);

    assert(buff.write([5, 4, 3, 2, 1]));
    assert(buff.read(elems, 5));
    assert(elems == [5, 4, 3, 2, 1]);
    assert(buff.size == 0);
    assert(buff.readIndex == 0);
    assert(buff.writeIndex == 0);
}

@safe unittest
{
    auto buff = RingBuffer!(int, 6, false).init;
    buff.initialize;

    assert(buff.write([1, 2, 3, 4, 5, 6]));
    assert(buff.isFull);

    int[3] elems;
    assert(buff.read(elems, 3));
    assert(elems == [1, 2, 3]);

    assert(buff.write([7, 8, 9]));

    assert(buff.read(elems, 3));
    assert(elems == [4, 5, 6]);

    assert(buff.read(elems, 3));
    assert(elems == [7, 8, 9]);
}

@safe unittest
{
    auto buff = RingBuffer!(int, 4, false).init;
    buff.initialize;

    assert(buff.write([1, 2]));
    assert(buff.writeIndex == 2);

    int[2] tempBuff = 0;
    // assert(!buff.read(tempBuff, 3));
    // assert(tempBuff == [0, 0]);

    assert(buff.read(tempBuff, 2));
    assert(tempBuff.length == 2);
    assert(tempBuff == [1, 2]);
    assert(buff.readIndex == 2);
    assert(buff.writeIndex == 2);
    assert(buff.isEmpty);

    assert(buff.write([3, 4, 5, 6]));
    assert(buff.isFull);
    assert(buff.size == 4);
    assert(buff.readIndex == 2);
    assert(buff.writeIndex == 2);
}

unittest
{
    auto buff = RingBuffer!(int, 6, false).init;
    buff.initialize;

    assert(buff.write([1, 2, 3, 4, 5, 6]));

    assert(buff.read((end, start) {
            assert(end.length == 3);
            assert(end == [1, 2, 3]);
            assert(start.length == 0);
        }, 3));
    assert(buff.readIndex == 3);
    assert(buff.size == 3);

    assert(buff.write([7, 8, 9]));
    assert(buff.writeIndex == 3);
    assert(buff.size == 6);

    assert(buff.read((end, start) {
            assert(end.length == 3);
            assert(end == [4, 5, 6]);
            assert(start.length == 3);
            assert(start == [7, 8, 9]);
        }, 6));
    assert(buff.readIndex == 3);
    assert(buff.isEmpty);
}

unittest
{
    auto buff = RingBuffer!(int, 6, false).init;
    buff.initialize;

    assert(buff.write([1, 2, 3, 4, 5, 6]));
    assert(buff.isFull);
    assert(buff.size == 6);

    int elem;
    assert(buff.read(elem));

    assert(elem == 1);
    assert(buff.size == 5);

    foreach (i; 1 .. 6)
    {
        assert(buff.read(elem));
        assert(elem == i + 1);
        assert(buff.size == 5 - i);
    }

    assert(buff.size == 0);
    assert(buff.isEmpty);
}
