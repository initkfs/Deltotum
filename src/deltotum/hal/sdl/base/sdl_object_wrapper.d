module deltotum.hal.sdl.base.sdl_object_wrapper;

import deltotum.hal.object.hal_object_wrapper: HalObjectWrapper;
import deltotum.hal.sdl.base.sdl_object : SdlObject;

import std.exception : enforce;

/**
 * Authors: initkfs
 */
abstract class SdlObjectWrapper(T) : SdlObject
{
    mixin HalObjectWrapper!T;
}
