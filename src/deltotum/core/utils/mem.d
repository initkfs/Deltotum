module deltotum.core.utils.mem;

import core.memory : GC;

/**
 * Authors: initkfs
 */

private
{
    enum noMoveGcAttr = GC.BlkAttr.NO_MOVE;
}

void addRange(void[] mem)
{
    GC.addRange(mem.ptr, mem.length);
}

void addRootSafe(void* ptr)
{
    GC.addRoot(ptr);
    GC.setAttr(ptr, noMoveGcAttr);
}

void removeRootSafe(void* ptr)
{
    GC.removeRoot(ptr);
    GC.clrAttr(ptr, noMoveGcAttr);
}
