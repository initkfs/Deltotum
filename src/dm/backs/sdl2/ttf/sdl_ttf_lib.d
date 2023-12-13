module dm.backs.sdl2.ttf.sdl_ttf_lib;

// dfmt off
version(SdlBackend):
// dfmt on

import dm.backs.sdl2.ttf.base.sdl_ttf_object : SdlTTFObject;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlTTFLib : SdlTTFObject
{

    void initialize() const
    {
        auto loadResult = loadSDLTTF();
        if (loadResult != sdlTTFSupport)
        {
            string error = "Unable to load SDL_ttf library.";
            if (loadResult == SDLTTFSupport.noLibrary)
            {
                error ~= " The SDL_ttf shared library failed to load.";
            }
            else if (loadResult == SDLTTFSupport.badLibrary)
            {
                error ~= " One or more symbols in SDL_ttf failed to load.";
            }

            throw new Exception(error);
        }

        int initResult = TTF_Init();
        if (initResult < 0)
        {
            string error = "Unable to initialize SDL_ttf library.";
            if (const err = getError)
            {
                error ~= err;
            }
            throw new Exception(error);
        }
    }

    void quit() const @nogc nothrow
    {
        TTF_Quit();
    }

}
