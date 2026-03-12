module api.dm.back.sdl3.base.sdl_object_wrapper;

import api.dm.com.ptrs.com_ptr_manager : ComPtrManager;
import api.dm.back.sdl3.base.sdl_object : SdlObjectMixin;

/**
 * Authors: initkfs
 */
abstract class SdlObjectWrapper(T) : ComPtrManager!T
{
    mixin SdlObjectMixin;

    this()
    {

    }

    this(T* newPtr)
    {
        super(newPtr);
    }
}
