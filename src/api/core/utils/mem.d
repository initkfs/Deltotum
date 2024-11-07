module api.core.utils.mem;

import core.memory : GC;

/**
 * Authors: initkfs
 */

private
{
    enum noMoveGcAttr = GC.BlkAttr.NO_MOVE;
}

void addRange(void[] mem) @nogc nothrow
{
    GC.addRange(mem.ptr, mem.length);
}

void addRootSafe(void* ptr) nothrow
{
    GC.addRoot(ptr);
    GC.setAttr(ptr, noMoveGcAttr);
}

void removeRootSafe(void* ptr) nothrow
{
    GC.removeRoot(ptr);
    GC.clrAttr(ptr, noMoveGcAttr);
}
