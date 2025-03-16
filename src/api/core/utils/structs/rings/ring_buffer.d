module api.core.utils.structs.rings.ring_buffer;

/**
 * Authors: initkfs
 */
struct RingBuffer(BufferType, size_t BufferSize)
{
    protected
    {
        BufferType[BufferSize] _buffer;
        size_t _readIndex; //remove
        size_t _writeIndex; //add
        size_t _size;
    }

    const @nogc nothrow
    {
        bool isEmpty() => _size == 0;
        bool isFull() => _size == BufferSize;
        size_t capacity() => BufferSize - size;
    }

    bool put(BufferType[] items)
    {
        size_t itemsLen = items.length;

        if (itemsLen == 0 || isFull)
        {
            return false;
        }

        size_t rest = writeIndex == 0 ? BufferSize : BufferSize - writeIndex;

        size_t buffLen = itemsLen;

        if (buffLen <= rest)
        {
            size_t endIndex = writeIndex + buffLen;
            buffer[writeIndex .. endIndex] = items;
            writeIndex = endIndex;
            if (writeIndex >= BufferSize)
            {
                writeIndex = 0;
            }
            size += buffLen;
            return true;
        }

        size_t lastElems = rest;
        size_t firstElems = buffLen - lastElems;

        size_t endIndex = writeIndex + lastElems;

        buffer[writeIndex .. endIndex] = items[0 .. lastElems];
        buffer[0 .. firstElems] = items[lastElems .. $];

        writeIndex = firstElems;
        if (writeIndex >= BufferSize)
        {
            writeIndex = 0;
        }
        size += lastElems;

        return true;
    }

    bool get(out BufferType[] elements, size_t count) nothrow
    {
        if (isEmpty)
        {
            return false;
        }

        if (size < count)
        {
            return false;
        }

        const endIndex = readIndex + count;
        if (endIndex > BufferSize)
        {
            return false;
        }

        elements = buffer[readIndex .. endIndex];
        readIndex = endIndex;
        if (readIndex >= BufferSize)
        {
            readIndex = 0;
        }
        size -= count;
        return true;
    }

    void reset() @nogc nothrow
    {
        writeIndex = 0;
        readIndex = 0;
        buffer = BufferType.init;
        size = 0;
    }

    void onItem(scope bool delegate(BufferType) onItemIsContinue)
    {
        foreach (i; 0 .. size)
        {
            size_t index = (readIndex + i) % BufferSize;
            if (!onItemIsContinue(buffer[index]))
            {
                break;
            }
        }
    }
}

unittest
{
    auto buff = new RingBuffer!(int, 5);
    buff.put([1, 2, 3]);
    assert(buff.size == 3);
    assert(buff.writeIndex == 3);
    assert(buff.buffer == [1, 2, 3, 0, 0]);

    buff.reset;
    assert(buff.size == 0);
    assert(buff.writeIndex == 0);
    assert(buff.buffer == [0, 0, 0, 0, 0]);

    buff.put([1, 2, 3]);

    int[] elems = [];
    assert(buff.get(elems, 1));
    assert(buff.readIndex == 1);
    assert(buff.size == 2);
    assert(buff.buffer == [1, 2, 3, 0, 0]);
    assert(elems == [1]);

    assert(buff.get(elems, 2));
    assert(buff.readIndex == 3);
    assert(buff.size == 0);
    assert(buff.buffer == [1, 2, 3, 0, 0]);
    assert(elems == [2, 3]);
}

unittest
{
    auto buff = new RingBuffer!(int, 5);
    buff.put([1, 2, 3, 4, 5]);
    assert(buff.isFull);

    int[] elems;
    assert(buff.get(elems, 5));
    assert(elems == [1, 2, 3, 4, 5]);
    assert(buff.size == 0);
    assert(buff.readIndex == 0);
    assert(buff.writeIndex == 0);

    buff.put([5, 4, 3, 2, 1]);
    assert(buff.get(elems, 5));
    assert(elems == [5, 4, 3, 2, 1]);
    assert(buff.size == 0);
    assert(buff.readIndex == 0);
    assert(buff.writeIndex == 0);
}
