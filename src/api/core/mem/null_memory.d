module api.core.mem.null_memory;

import api.core.mem.memory : Memory;
import api.core.mem.allocs.null_allocator : NullAllocator;

/**
 * Authors: initkfs
 */
class NullMemory : Memory
{
    this() @safe
    {
        super(new NullAllocator);
    }

    this() const @safe
    {
        const nc = new const NullAllocator;
        super(nc);
    }

    this() immutable @safe
    {
        super(new immutable NullAllocator);
    }

}
