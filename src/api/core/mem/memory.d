module api.core.mem.memory;

import api.core.components.component_service : ComponentService;
import api.core.mem.allocs.allocator : Allocator;

/**
 * Authors: initkfs
 */
class Memory : ComponentService
{
    Allocator alloc;

    this(Allocator allocator) pure @safe
    {
        assert(allocator);
        this.alloc = allocator;
    }

    this(const Allocator allocator) const pure @safe
    {
        assert(allocator);
        this.alloc = allocator;
    }

    this(immutable Allocator allocator) immutable pure @safe
    {
        assert(allocator);
        this.alloc = allocator;
    }

}
