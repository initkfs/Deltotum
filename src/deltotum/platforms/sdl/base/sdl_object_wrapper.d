module deltotum.platforms.sdl.base.sdl_object_wrapper;

import deltotum.platforms.object.platform_object_wrapper: PlatformObjectWrapper;
import deltotum.platforms.sdl.base.sdl_object : SdlObject;

import std.exception : enforce;

/**
 * Authors: initkfs
 */
abstract class SdlObjectWrapper(T) : SdlObject
{
    mixin PlatformObjectWrapper!T;
}
