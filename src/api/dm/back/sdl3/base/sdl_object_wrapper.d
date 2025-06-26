module api.dm.back.sdl3.base.sdl_object_wrapper;

import api.dm.com.platforms.objects.com_ptr_manager : ComPtrManager;
import api.dm.back.sdl3.base.sdl_object : SdlObject;

import std.exception : enforce;

/**
 * Authors: initkfs
 */
abstract class SdlObjectWrapper(T) : SdlObject
{
    mixin ComPtrManager!T;
}
