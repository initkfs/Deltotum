module deltotum.sys.cairo.base.cairo_object_wrapper;


import deltotum.com.objects.platform_object_wrapper : PlatformObjectWrapper;

import std.exception : enforce;

/**
 * Authors: initkfs
 */
abstract class CairoObjectWrapper(T)
{
    mixin PlatformObjectWrapper!T;
}
