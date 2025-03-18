module api.core.utils.structs.rings.ring_buffer;

import api.core.utils.structs.container_result : ContainerResult;

import core.sync.mutex : Mutex;

//import core.atomic;

/**
 * Authors: initkfs
 */
struct RingBuffer(BufferType, size_t BufferSize, bool isWithMutex = true)
{
    private
    {
        BufferType[BufferSize] _buffer;
        size_t _readIndex; //remove
        size_t _writeIndex; //add
        size_t _size;
        bool _lock;
    }

    static if (isWithMutex)
    {
        shared Mutex mutex;

        this(shared Mutex m) pure @safe @nogc nothrow
        {
            assert(m);
            mutex = m;
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

        ContainerResult writeSync(const BufferType[] items) @nogc @safe
        {
            synchronized (mutex)
            {
                return write(items);
            }
        }

        ContainerResult writeIfNoLockedSync(const BufferType[] items) @nogc @safe
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

        ContainerResult readifNoLockedSync(BufferType[] elements, size_t count) @nogc @safe
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

        ContainerResult readSync(BufferType[] elements, size_t count) @nogc @safe
        {
            synchronized (mutex)
            {
                return read(elements, count);
            }
        }
    }

    ContainerResult write(const BufferType[] items) nothrow @safe
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
        //atomicOp!"+="(_size, lastElems);
        _size += lastElems;

        return ContainerResult.success;
    }

    ContainerResult read(scope BufferType[] elements, size_t count) nothrow @nogc @safe
    {
        if (_lock)
        {
            return ContainerResult.locked;
        }

        if (isEmpty)
        {
            return ContainerResult.empty;
        }

        if (_size < count)
        {
            return ContainerResult.nofilled;
        }

        const endIndex = _readIndex + count;
        if (endIndex > BufferSize)
        {
            return ContainerResult.fail;
        }

        elements[0 .. count] = _buffer[_readIndex .. endIndex];
        _readIndex = endIndex;
        if (_readIndex >= BufferSize)
        {
            _readIndex = 0;
        }
        //atomicOp!"-="(_size, count);
        _size -= count;
        return ContainerResult.success;
    }

    void reset() @nogc nothrow @safe
    {
        _writeIndex = 0;
        _readIndex = 0;
        _buffer = BufferType.init;
        _size = 0;
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
