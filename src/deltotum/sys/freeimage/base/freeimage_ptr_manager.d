module deltotum.sys.freeimage.base.freeimage_ptr_manager;

import deltotum.com.platforms.objects.com_ptr_manager: ComPtrManager;

/**
 * Authors: initkfs
 */
class FreeImagePtrManager(T)
{
    mixin ComPtrManager!T;
}
