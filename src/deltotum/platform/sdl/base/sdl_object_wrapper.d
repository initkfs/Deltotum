module deltotum.platform.sdl.base.sdl_object_wrapper;

import deltotum.platform.object.platform_object_wrapper: PlatformObjectWrapper;
import deltotum.platform.sdl.base.sdl_object : SdlObject;

import std.exception : enforce;

/**
 * Authors: initkfs
 */
abstract class SdlObjectWrapper(T) : SdlObject
{
    mixin PlatformObjectWrapper!T;
}
