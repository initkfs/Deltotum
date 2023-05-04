module deltotum.sys.cairo.base.cairo_object_wrapper;

import deltotum.com.platforms.objects.com_ptr_manager : ComPtrManager;

import std.exception : enforce;

/**
 * Authors: initkfs
 */
abstract class CairoObjectWrapper(T)
{
    mixin ComPtrManager!T;
}
