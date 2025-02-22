module api.dm.back.sdl3.ttf.sdl_ttf_lib;

// dfmt off
version(SdlBackend):
// dfmt on

import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.back.sdl3.ttf.base.sdl_ttf_object : SdlTTFObject;

import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */
class SdlTTFLib : SdlTTFObject
{

    ComResult initialize() const
    {
        if (!TTF_Init())
        {
            return getErrorRes("Unable to initialize SDL_ttf library.");
        }
        return ComResult.success;
    }

    void quit() const nothrow
    {
        TTF_Quit();
    }

}
