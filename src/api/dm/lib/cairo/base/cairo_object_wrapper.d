module api.dm.lib.cairo.base.cairo_object_wrapper;

import api.dm.com.ptrs.com_ptr_manager : ComPtrManager;

/**
 * Authors: initkfs
 */
abstract class CairoObjectWrapper(T) : ComPtrManager!T
{
    this(T* newPtr)
    {
        super(newPtr);
    }

    this()
    {

    }
}
