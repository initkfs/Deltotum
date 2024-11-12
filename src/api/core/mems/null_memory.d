module api.core.mems.null_memory;

import api.core.mems.memory : Memory;
import api.core.mems.allocs.null_allocator : NullAllocator;

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
