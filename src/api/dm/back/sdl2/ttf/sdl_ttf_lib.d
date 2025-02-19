module api.dm.back.sdl2.ttf.sdl_ttf_lib;

// dfmt off
version(SdlBackend):
// dfmt on

import api.dm.back.sdl2.ttf.base.sdl_ttf_object : SdlTTFObject;

import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */
class SdlTTFLib : SdlTTFObject
{

    void initialize() const
    {
        if (!TTF_Init())
        {
            string error = "Unable to initialize SDL_ttf library.";
            if (const err = getError)
            {
                error ~= err;
            }
            throw new Exception(error);
        }
    }

    void quit() const nothrow
    {
        TTF_Quit();
    }

}
