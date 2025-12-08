module api.dm.back.sdl3.fonts.sdl_ttf_lib;

import api.dm.com.com_result : ComResult;
import api.dm.back.sdl3.base.sdl_object : SdlObject;

import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */
class SdlTTFLib : SdlObject
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
