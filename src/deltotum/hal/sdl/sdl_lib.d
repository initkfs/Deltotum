module deltotum.hal.sdl.sdl_lib;

import std.string : toStringz, fromStringz;

import bindbc.sdl;
import bindbcConfig = bindbc.sdl.config;

import deltotum.hal.sdl.base.sdl_object : SdlObject;

/**
 * Authors: initkfs
 */
class SdlLib : SdlObject
{
    void initialize(uint flags = SDL_INIT_EVERYTHING) const
    {
        SDLSupport loadResult = loadSDL();
        if (loadResult != bindbcConfig.sdlSupport)
        {
            string error = "Unable to load sdl.";
            if (loadResult == SDLSupport.noLibrary)
            {
                error ~= " The SDL shared library failed to load.";
            }
            else if (loadResult == SDLSupport.badLibrary)
            {
                error ~= " One or more SDL symbols failed to load.";
            }

            throw new Exception(error);
        }

        const result = SDL_Init(flags);
        if (result != 0)
        {
            string initError = "Unable to initialize sdl subsystems.";
            if (auto error = getError)
            {
                initError ~= error;
            }

            throw new Exception(initError);
        }
    }

    uint wasInit(uint flags) const @nogc nothrow
    {
        return SDL_WasInit(flags);
    }

    void quit() const @nogc nothrow
    {
        SDL_Quit();
    }
}
