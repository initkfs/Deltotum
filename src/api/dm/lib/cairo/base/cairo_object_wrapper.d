module api.dm.lib.cairo.base.cairo_object_wrapper;

import api.dm.com.objects.com_ptr_manager : ComPtrManager;

/**
 * Authors: initkfs
 */
abstract class CairoObjectWrapper(T)
{
    mixin ComPtrManager!T;
}
