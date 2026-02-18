module api.core.mems.memory;

import api.core.components.component_service : ComponentService;
import api.core.utils.allocs.allocator : Allocator;
import api.core.utils.allocs.arena_allocator : ArenaAllocator;

/**
 * Authors: initkfs
 */
class Memory : ComponentService
{
    Allocator* alloc;
    ArenaAllocator* arena;

    this(Allocator* allocator, ArenaAllocator* arenaAllocator) pure @safe
    {
        if (!allocator)
        {
            throw new Exception("Allocator must not be null");
        }

        if (!arenaAllocator)
        {
            throw new Exception("Arena must not be null");
        }
        this.alloc = allocator;
        this.arena = arenaAllocator;
    }

    this(const Allocator* allocator, const ArenaAllocator* arenaAllocator) const pure @safe
    {
        if (!allocator)
        {
            throw new Exception("Allocator must not be null");
        }

        if (!arenaAllocator)
        {
            throw new Exception("Arena must not be null");
        }
        this.alloc = allocator;
        this.arena = arenaAllocator;
    }

    this(immutable Allocator* allocator, immutable ArenaAllocator* arenaAllocator) immutable pure @safe
    {
        if (!allocator)
        {
            throw new Exception("Allocator must not be null");
        }

        if (!arenaAllocator)
        {
            throw new Exception("Arena must not be null");
        }
        this.alloc = allocator;
        this.arena = arenaAllocator;
    }

}
