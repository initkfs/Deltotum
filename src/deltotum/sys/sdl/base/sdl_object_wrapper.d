module deltotum.sys.sdl.base.sdl_object_wrapper;

// dfmt off
version(SdlBackend):
// dfmt on

import deltotum.com.platforms.objects.com_ptr_manager : ComPtrManager;
import deltotum.sys.sdl.base.sdl_object : SdlObject;

import std.exception : enforce;

/**
 * Authors: initkfs
 */
abstract class SdlObjectWrapper(T) : SdlObject
{
    mixin ComPtrManager!T;
}
