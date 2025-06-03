module api.core.mems.memory;

import api.core.components.component_service : ComponentService;
import api.core.util.allocs.allocator : Allocator;

/**
 * Authors: initkfs
 */
class Memory : ComponentService
{
    Allocator!ubyte alloc;

    this(Allocator!ubyte allocator) pure @safe
    {
        assert(allocator);
        this.alloc = allocator;
    }

    this(const Allocator!ubyte allocator) const pure @safe
    {
        assert(allocator);
        this.alloc = allocator;
    }

    this(immutable Allocator!ubyte allocator) immutable pure @safe
    {
        assert(allocator);
        this.alloc = allocator;
    }

}
