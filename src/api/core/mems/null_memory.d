module api.core.mems.null_memory;

import api.core.mems.memory : Memory;
import api.core.mems.allocs.allocator : Allocator;
import api.core.mems.allocs.mallocator : Mallocator;
import api.core.mems.allocs.arena_allocator : ArenaAllocator;

/**
 * Authors: initkfs
 */
class NullMemory : Memory
{
    this() @trusted
    {
        super(cast(Allocator*) new Mallocator(Allocator.init), new ArenaAllocator(Allocator.init));
        arena.base = *alloc;
    }

    this() const @trusted
    {
        const nc = cast(const(Allocator*)) new const Mallocator(Allocator.init);
        const arena = new const ArenaAllocator(Allocator.init);
        super(nc, arena);
    }

    // this() immutable @trusted
    // {
    //     immutable nc = cast(immutable(Allocator*)) (new immutable Mallocator(Allocator.init));
    //     immutable arena = new immutable ArenaAllocator(Allocator.init);
    //     super(nc, arena);
    // }

}
