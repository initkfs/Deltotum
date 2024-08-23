module api.dm.back.sdl2.base.sdl_object_wrapper;

// dfmt off
version(SdlBackend):
// dfmt on

import api.dm.com.platforms.objects.com_ptr_manager : ComPtrManager;
import api.dm.back.sdl2.base.sdl_object : SdlObject;

import std.exception : enforce;

/**
 * Authors: initkfs
 */
abstract class SdlObjectWrapper(T) : SdlObject
{
    mixin ComPtrManager!T;
}
