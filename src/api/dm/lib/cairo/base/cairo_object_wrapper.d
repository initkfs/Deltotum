module api.dm.lib.cairo.base.cairo_object_wrapper;

import api.dm.com.platforms.objects.com_ptr_manager : ComPtrManager;

import std.exception : enforce;

/**
 * Authors: initkfs
 */
abstract class CairoObjectWrapper(T)
{
    mixin ComPtrManager!T;
}
