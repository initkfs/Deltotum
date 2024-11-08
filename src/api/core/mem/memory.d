module api.core.mem.memory;

import api.core.components.component_service : ComponentService;
import api.core.mem.allocs.allocator : Allocator;

/**
 * Authors: initkfs
 */
class Memory : ComponentService
{
    Allocator alloc;

    this(Allocator allocator)
    {
        assert(allocator);
        this.alloc = allocator;
    }

}
