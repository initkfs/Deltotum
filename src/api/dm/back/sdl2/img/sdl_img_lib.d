module api.dm.back.sdl2.img.sdl_img_lib;

// dfmt off
version(SdlBackend):
// dfmt on

import api.dm.back.sdl2.img.base.sdl_image_object : SdlImageObject;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlImgLib : SdlImageObject
{

    void initialize(int flags = IMG_INIT_JPG | IMG_INIT_PNG) const
    {
        auto loadResult = loadSDLImage();
        if (loadResult != sdlImageSupport)
        {
            string error = "Unable to load SDL_image.";
            if (loadResult == SDLImageSupport.noLibrary)
            {
                error ~= " The SDL_image shared library failed to load.";
            }
            else if (loadResult == SDLImageSupport.badLibrary)
            {
                error ~= " One or more symbols in SDL_image failed to load.";
            }

            throw new Exception(error);
        }

        int initResult = IMG_Init(flags);
        if ((initResult & flags) != flags)
        {
            string error = "Unable to initialize SDL_Image library.";
            if (const err = getError)
            {
                error ~= err;
            }
            throw new Exception(error);
        }
    }

    void quit() const nothrow
    {
        IMG_Quit();
    }

}
