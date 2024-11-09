module api.core.mem.null_memory;

import api.core.mem.memory : Memory;
import api.core.mem.allocs.null_allocator: NullAllocator;

/**
 * Authors: initkfs
 */
class NullMemory : Memory
{
    this() pure @safe
    {
        super(new NullAllocator);
    }

    this() const pure @safe
    {
        const nc = new const NullAllocator;
        super(nc);
    }

    this() immutable pure @safe
    {
        super(new immutable NullAllocator);
    }

}
