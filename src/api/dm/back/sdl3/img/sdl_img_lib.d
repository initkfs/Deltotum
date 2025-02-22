module api.dm.back.sdl3.img.sdl_img_lib;

// dfmt off
version(SdlBackend):
// dfmt on

import api.dm.back.sdl3.img.base.sdl_image_object : SdlImageObject;

import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */
class SdlImgLib : SdlImageObject
{

    ComResult initialize() const
    {
        return ComResult.success;
    }

    void quit() const nothrow
    {
        
    }

}
