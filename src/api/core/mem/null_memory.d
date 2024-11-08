module api.core.mem.null_memory;

import api.core.mem.memory: Memory;
import api.core.mem.allocs.mallocator: Mallocator;

/**
 * Authors: initkfs
 */
class NullMemory : Memory
{
    this()
    {
       super(new Mallocator);
    }

}