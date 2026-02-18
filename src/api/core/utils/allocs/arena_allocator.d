module api.core.utils.allocs.arena_allocator;

import api.core.utils.allocs.allocator : Allocator;

/**
 * Authors: initkfs
 */
struct Block
{
    Block* next;
    ubyte[] buffer;
    size_t offset;
    size_t maxOffset;
    size_t totalUsed;

    size_t alignedOffset(size_t alignSizePowerOf2) const nothrow pure @safe
    {
        if (alignSizePowerOf2 <= 1)
        {
            return offset;
        }
        alignSizePowerOf2--;
        return (offset + alignSizePowerOf2) & ~(alignSizePowerOf2);
    }

    bool canAlloc(size_t size, size_t alignSizePowerOf2) const nothrow pure @safe
    {
        if (offset >= buffer.length)
        {
            return false;
        }

        return (alignedOffset(alignSizePowerOf2) + size) <= buffer.length;
    }

    ubyte[] alloc(size_t size, size_t alignSize)
    {
        size_t newOffset = alignedOffset(alignSize);
        size_t endOffset = newOffset + size;
        auto result = buffer[newOffset .. endOffset];
        offset = endOffset;
        totalUsed += size;
        if (endOffset > maxOffset)
        {
            maxOffset = endOffset;
        }

        return result;
    }

    void resetHistory()
    {
        offset = 0;
        maxOffset = 0;
        totalUsed = 0;
    }
}

struct Stats
{
    size_t totalBlocks;
    size_t totalMemory;
    size_t usedMemory;
    size_t wastedMemory; // round to pageSize
    size_t allocations;
}

struct ArenaAllocator
{
    Allocator base;

    size_t pageSize;
    size_t allocations;
    Block* firstBlock;
    Block* currentBlock;

    bool isUseAlignAlloc;

    this(Allocator base) pure nothrow @safe
    {
        this.base = base;
    }

    void create(size_t initialSize, size_t pageSize = 16) @trusted
    {
        assert(pageSize > 0);
        this.pageSize = pageSize;
        firstBlock = createBlock(initialSize);
        currentBlock = firstBlock;
    }

    T[] array(T)(size_t count, size_t alignSize = 0) @trusted
    {
        if (count > size_t.max / T.sizeof)
        {
            return null;
        }
        size_t size = count * T.sizeof;
        size_t alignDataSize = alignSize > T.alignof ? alignSize : T.alignof;

        assert(alignDataSize <= pageSize);

        if (!currentBlock.canAlloc(size, alignDataSize))
        {
            Block* newBlock = createBlock(size);
            assert(newBlock);
            currentBlock.next = newBlock;
            currentBlock = newBlock;
        }

        auto result = cast(T[]) currentBlock.alloc(size, alignDataSize);
        allocations++;
        return result;
    }

    Block* createBlock(size_t initialSize)
    {
        assert(base.allocFunPtr);
        assert(base.allocAlignFunPtr);

        ubyte[] blockBuff;
        if (!base.allocFunPtr(Block.sizeof, blockBuff))
        {
            return null;
        }

        Block* newBlock = (cast(Block[]) blockBuff).ptr;
        newBlock.next = null;
        newBlock.buffer = null;
        newBlock.offset = 0;

        ubyte[] blockData;
        bool isAlloc = !isUseAlignAlloc ? base.allocFunPtr(roundToPageSize(initialSize), blockData)
            : base.allocAlignFunPtr(
                roundToPageSize(initialSize), blockData, pageSize);
        if (!isAlloc)
        {
            if (blockBuff.length > 0)
            {
                assert(base.freeFunPtr);
                base.freeFunPtr(blockBuff.ptr);
            }
            return null;
        }

        newBlock.buffer = blockData;

        return newBlock;
    }

    protected size_t roundToPageSize(size_t size) nothrow @trusted
    {
        if (pageSize == 0)
        {
            return size;
        }

        if (size <= pageSize)
        {
            return pageSize;
        }

        //round up
        auto pageSizeDec = pageSize - 1;
        return (size + pageSizeDec) & ~(pageSizeDec);
    }

    Block* findBlock(size_t size, size_t alignSize)
    {
        if (currentBlock && currentBlock.canAlloc(size, alignSize))
        {
            return currentBlock;
        }

        auto block = firstBlock;
        while (block)
        {
            if (block.canAlloc(size, alignSize))
            {
                return block;
            }

            block = block.next;
        }

        return null;
    }

    void resetAll()
    {
        auto block = firstBlock;
        while (block)
        {
            block.offset = 0;
            block.totalUsed = 0;
            block = block.next;
        }
    }

    void freeAll() @trusted
    {
        assert(base.freeFunPtr);
        auto block = firstBlock;
        while (block)
        {
            auto blockPtr = block;
            block = block.next;

            base.freeFunPtr(blockPtr.buffer.ptr);
            base.freeFunPtr(blockPtr);
        }

        firstBlock = null;
        currentBlock = null;
    }

    Stats getStats()
    {
        Stats result;
        result.allocations = allocations;

        auto block = firstBlock;
        while (block)
        {
            result.totalBlocks++;
            result.totalMemory += block.buffer.length;
            result.usedMemory += block.offset;
            block = block.next;
        }

        result.wastedMemory = result.totalMemory - result.usedMemory;
        return result;
    }
}

unittest
{
    import api.core.utils.allocs.mallocator : initMallocator;

    Block block1;
    block1.buffer = new ubyte[12];
    block1.offset = 1;
    assert(block1.alignedOffset(0) == 1);
    assert(block1.alignedOffset(1) == 1);
    assert(block1.alignedOffset(2) == 2);
    assert(block1.alignedOffset(4) == 4);
    block1.offset = 7;
    assert(block1.alignedOffset(16) == 16);

    block1.offset = 0;
    auto buff1 = block1.alloc(3, 4);
    assert(buff1.length == 3);
    assert(buff1.ptr == block1.buffer.ptr);
    assert(block1.offset == 3);
    auto buff2 = block1.alloc(2, 4);
    assert(buff2.length == 2);
    assert(buff2.ptr == block1.buffer.ptr + 4);
    assert(block1.offset == 6);
    auto buff3 = block1.alloc(3, 4);
    assert(buff3.length == 3);
    assert(buff3.ptr == block1.buffer.ptr + 8);
    assert(block1.offset == 11);
    assert(!block1.canAlloc(1, 4));

    block1.offset = 8;
    assert(block1.canAlloc(4, 4)); // 8+4=12
    auto buff4 = block1.alloc(4, 4);
    assert(buff4.ptr == block1.buffer.ptr + 8);
    assert(block1.offset == 12);

}

unittest
{
    import api.core.utils.allocs.mallocator : initMallocator;

    auto allocator = new ArenaAllocator;
    initMallocator(cast(Allocator*) allocator);
    allocator.create(16, 32);

    auto bytes1 = allocator.array!ubyte(4);
    assert(bytes1.length == 4);
    assert(allocator.currentBlock.offset == 4);

    auto bytes2 = allocator.array!ubyte(8);
    assert(bytes2.length == 8);
    assert(allocator.currentBlock.offset == 12); // 4 + 8 = 12

    // Base align
    struct S16
    {
        ubyte[16] data;
    }

    struct S8
    {
        ubyte[8] data;
    }

    auto aligned1 = allocator.array!S16(1, 8);
    assert(aligned1.length == 1);
    assert(allocator.currentBlock.offset == 32);

    // Create new block
    auto oldBlock = allocator.currentBlock;
    auto bytes3 = allocator.array!ubyte(40);
    assert(bytes3.length == 40);
    assert(allocator.currentBlock !is oldBlock);
    assert(allocator.currentBlock.offset == 40);

    // Check block chain
    assert(allocator.firstBlock);
    assert(allocator.firstBlock.next is allocator.currentBlock ||
            allocator.firstBlock is allocator.currentBlock);

    // canAlloc 
    assert(allocator.findBlock(10, 1));

    // resetAll
    auto blockBeforeReset = allocator.currentBlock;
    allocator.resetAll;
    assert(allocator.currentBlock.offset == 0);
    assert(blockBeforeReset.offset == 0);
    auto newInts = allocator.array!int(10);
    assert(newInts.length == 10);

    // freeAll
    allocator.freeAll;
    assert(allocator.firstBlock is null);
    assert(allocator.currentBlock is null);

    //Test align
    auto aallocator = new ArenaAllocator;
    initMallocator(cast(Allocator*) aallocator);
    aallocator.isUseAlignAlloc = true;
    aallocator.create(64, 64);

    auto bigAligned = aallocator.array!ubyte(4, 64);
    assert(bigAligned.length == 4);
    assert(((cast(size_t) bigAligned.ptr) & 63) == 0);

    allocator = new ArenaAllocator;
    allocator.isUseAlignAlloc = true;
    initMallocator(cast(Allocator*) allocator);
    allocator.create(32, 64);

    struct Align16
    {
        align(16) ubyte[16] data;
    }

    static assert(Align16.alignof == 16);

    struct Align8
    {
        align(8) ubyte[8] data;
    }

    static assert(Align8.alignof == 8);

    auto a16 = allocator.array!Align16(2);
    assert(a16.length == 2);
    assert((cast(size_t) a16.ptr & 15) == 0); // 16

    auto a8 = allocator.array!Align8(3);
    assert(a8.length == 3);
    assert((cast(size_t) a8.ptr & 7) == 0); // 8

    auto a16_align32 = allocator.array!Align16(1, 32);
    assert(a16_align32.length == 1);
    assert((cast(size_t) a16_align32.ptr & 31) == 0); // 32
}
