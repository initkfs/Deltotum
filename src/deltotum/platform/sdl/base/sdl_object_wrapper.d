module deltotum.platform.sdl.base.sdl_object_wrapper;

// dfmt off
version(SdlBackend):
// dfmt on

import deltotum.platform.objects.platform_object_wrapper : PlatformObjectWrapper;
import deltotum.platform.sdl.base.sdl_object : SdlObject;

import std.exception : enforce;

/**
 * Authors: initkfs
 */
abstract class SdlObjectWrapper(T) : SdlObject
{
    mixin PlatformObjectWrapper!T;
}
