module api.core.utils.adt.rings.ring_buffer_lf;

import api.core.utils.adt.container_result : ContainerResult;
import api.core.utils.adt.buffers.dense_buffer : DenseBuffer;

import core.atomic;

import Math = api.math;

/**
 * Authors: initkfs
 * Simple Single Producer, Single Consumer (SPSC) buffer
 */
struct RingBufferLF(BufferType, size_t RequestBufferSize, bool isStaticArray = false, bool isLockFree = true, size_t CacheLine = 64)
{
    private
    {
        enum BufferSize = Math.nextPowerOfTwo(RequestBufferSize);
        enum BufferSizeBitMask = BufferSize - 1;

        static if (isStaticArray)
        {
            BufferType[BufferSize] _buffer;
        }
        else
        {
            BufferType[] _buffer;
        }

        static if (isLockFree)
        {
            align(CacheLine) shared size_t _readIndex;
            byte[CacheLine - size_t.sizeof] _rpad;
            align(CacheLine) shared size_t _writeIndex;
            byte[CacheLine - size_t.sizeof] _wpad;
        }
        else
        {
            size_t _readIndex;
            size_t _writeIndex;
        }
    }

    void initialize()
    {
        import Math = api.math;

        static if (isLockFree)
        {
            _readIndex.atomicStore(0);
            _writeIndex.atomicStore(0);
        }

        static if (!isStaticArray)
        {
            _buffer = new BufferType[](BufferSize);
        }

        static if (__traits(isFloating, BufferType))
        {
            _buffer[] = 0;
        }
        else
        {
            _buffer[] = BufferType.init;
        }
    }

    static if (isLockFree)
    {
        size_t size() => size(_readIndex.atomicLoad, _writeIndex.atomicLoad);
    }
    else
    {
        size_t size() => size(_readIndex, _writeIndex);
    }

    private size_t size(size_t readIdx, size_t writeIdx)
    {
        return (writeIdx - readIdx) & ((BufferSizeBitMask << 1) | 1);
    }

    size_t write(BufferType[] buf)
    {
        static if (isLockFree)
        {
            size_t writeIdx = _writeIndex.atomicLoad!(MemoryOrder.raw);
            size_t readIdx = _readIndex.atomicLoad!(MemoryOrder.acq);
        }
        else
        {
            size_t writeIdx = _writeIndex;
            size_t readIdx = _readIndex;
        }

        size_t size = this.size(readIdx, writeIdx);

        if (size > BufferSize)
        {
            return 0;
        }

        size_t write = Math.min(BufferSize - size, buf.length);

        size_t currPosToEnd, fromStart;

        size_t countOverflow = (writeIdx & BufferSizeBitMask) + write;
        //TODO countOverflow == BufferSize
        if (countOverflow > BufferSize)
        {
            //fromStart = countOverflow & BufferSizeBitMask;
            fromStart = countOverflow - BufferSize;
            currPosToEnd = write - fromStart;
        }
        else
        {
            currPosToEnd = write;
            fromStart = 0;
        }

        size_t startIdx = writeIdx & BufferSizeBitMask;
        size_t endIdx = startIdx + currPosToEnd;
        _buffer[startIdx .. endIdx] = buf[0 .. currPosToEnd];

        if (fromStart)
        {
            _buffer[0 .. fromStart] = buf[currPosToEnd .. (currPosToEnd + fromStart)];
        }

        writeIdx = writeIdx + write;

        static if (isLockFree)
        {
            _writeIndex.atomicStore!(MemoryOrder.rel)(writeIdx);
        }
        else
        {
            _writeIndex = writeIdx;
        }

        return write;
    }

    size_t read(BufferType[] buf)
    {
        static if (isLockFree)
        {
            size_t readIdx = _readIndex.atomicLoad!(MemoryOrder.raw);
            size_t writeIdx = _writeIndex.atomicLoad!(MemoryOrder.acq);
        }
        else
        {
            size_t readIdx = _readIndex;
            size_t writeIdx = _writeIndex;
        }

        size_t size = this.size(readIdx, writeIdx);

        if (size > 0)
        {
            size_t currToEnd = void, fromStartAround = void;

            size_t read = Math.min(size, buf.length);
            size_t countOverflow = (readIdx & BufferSizeBitMask) + read;
            if (countOverflow > BufferSize)
            {
                //fromStartAround = countOverflow & BufferSizeBitMask;
                fromStartAround = countOverflow - BufferSize;
                currToEnd = read - fromStartAround;
            }
            else
            {
                currToEnd = read;
                fromStartAround = 0;
            }

            size_t startIdx = readIdx & BufferSizeBitMask;
            buf[0 .. currToEnd] = _buffer[startIdx .. startIdx + currToEnd];

            if (fromStartAround)
            {
                buf[currToEnd .. currToEnd + fromStartAround] = _buffer[0 .. fromStartAround];
            }

            readIdx = readIdx + read;
            static if (isLockFree)
            {
                _readIndex.atomicStore!(MemoryOrder.rel)(readIdx);
            }
            else
            {
                _readIndex = readIdx;
            }
            return read;
        }
        return 0;
    }

    inout(BufferType[]) raw() inout => _buffer;

}

unittest
{
    import std.stdio;
    import core.atomic : MemoryOrder;

    import Math = api.math;

    alias Buffer4 = RingBufferLF!(ubyte, 3, false);
    alias Buffer8 = RingBufferLF!(ubyte, 5, false);
    alias Buffer16 = RingBufferLF!(ubyte, 9, false);

    assert(Buffer4.BufferSize == 4);
    assert(Buffer8.BufferSize == 8);
    assert(Buffer16.BufferSize == 16);

    alias TestBuffer = RingBufferLF!(ubyte, 8, false);

    {
        TestBuffer buffer;
        buffer.initialize;

        ubyte[4] readBuf;
        size_t read = buffer.read(readBuf[]);
        assert(read == 0);
    }

    {
        RingBufferLF!(ubyte, 4) buffer;
        buffer.initialize;

        ubyte[4] dataToWrite = [1, 2, 3, 4];
        ubyte[4] readBuffer;

        size_t written = buffer.write(dataToWrite[]);
        assert(written == 4);
        assert(buffer.size == 4);

        size_t read = buffer.read(readBuffer[]);
        assert(read == 4);
        assert(readBuffer == [1, 2, 3, 4]);
        assert(buffer.size == 0);
    }

    // (countOverflow > BufferSize)
    {
        TestBuffer buffer;
        buffer.initialize;

        ubyte[6] data1 = [1, 2, 3, 4, 5, 6];
        size_t written1 = buffer.write(data1[]);
        assert(written1 == 6);

        ubyte[4] readBuf1;
        size_t fromStartAround = buffer.read(readBuf1[]);
        assert(fromStartAround == 4);

        // countOverflow = (6 & 7) + 6 = 6 + 6 = 12 > 8
        ubyte[6] data2 = [7, 8, 9, 10, 11, 12];
        size_t written2 = buffer.write(data2[]);
        assert(written2 == 6);
        assert(buffer.raw == [9, 10, 11, 12, 5, 6, 7, 8]);

        ubyte[8] readBuf2;
        size_t read2 = buffer.read(readBuf2[]);
        assert(read2 == 8);
        assert(readBuf2 == [5, 6, 7, 8, 9, 10, 11, 12]);
        assert(buffer.size == 0);
    }

    {
        TestBuffer buffer;
        buffer.initialize;

        ubyte[6] data1 = [1, 2, 3, 4, 5, 6];
        buffer.write(data1[]);

        ubyte[2] readBuf1;
        buffer.read(readBuf1[]);

        ubyte[4] data2 = [7, 8, 9, 10];
        buffer.write(data2[]);

        assert(buffer.raw == [9, 10, 3, 4, 5, 6, 7, 8]);

        TestBuffer buffer2;
        buffer2.initialize;

        ubyte[3] data3 = [11, 12, 13];
        buffer2.write(data3[]);

        ubyte[2] readBuf2;
        buffer2.read(readBuf2[]);

        ubyte[7] data4 = [14, 15, 16, 17, 18, 19, 20];
        size_t written = buffer2.write(data4[]);
        assert(written == 7);

        // countOverflow = (2 & 7) + 7 = 2 + 7 = 9 > 8
        ubyte[7] readBuf3;
        size_t read = buffer2.read(readBuf3[]);
        assert(read == 7);
        assert(readBuf3 == [13, 14, 15, 16, 17, 18, 19]);
    }

    {
        TestBuffer buffer;
        buffer.initialize;

        ubyte[8] data1 = [1, 2, 3, 4, 5, 6, 7, 8];
        size_t written1 = buffer.write(data1[]);
        assert(written1 == 8);

        ubyte[2] data2 = [9, 10];
        size_t written2 = buffer.write(data2[]);
        assert(written2 == 0);

        ubyte[4] readBuf;
        buffer.read(readBuf[]);

        size_t written3 = buffer.write(data2[]);
        assert(written3 == 2);
    }

    {
        TestBuffer buffer;
        buffer.initialize;

        ubyte[3] fromStart = [1, 2, 3];
        ubyte[5] write2 = [4, 5, 6, 7, 8];
        ubyte[4] write3 = [9, 10, 11, 12];

        ubyte[12] readBuf;

        buffer.write(fromStart[]);
        buffer.write(write2[]);

        size_t fromStartAround = buffer.read(readBuf[0 .. 5]); //5
        assert(fromStartAround == 5);

        buffer.write(write3[]);

        size_t read2 = buffer.read(readBuf[5 .. $]);
        assert(read2 == 7);
    }
}
