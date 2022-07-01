module deltotum.hal.sdl.sdl_lib;

import std.string: toStringz, fromStringz;

import bindbc.sdl;
import bindbcConfig = bindbc.sdl.config;

import deltotum.hal.sdl.base.sdl_object : SdlObject;

class SdlLib : SdlObject
{
    void initialize()
    {
        SDLSupport loadResult = loadSDL();
        if (loadResult != bindbcConfig.sdlSupport)
        {
            string error = "Unable to load sdl.";
            if (loadResult == SDLSupport.noLibrary)
            {
                error ~= " The SDL shared library failed to load.";
            }
            else if (SDLSupport.badLibrary)
            {
                error ~= " One or more SDL symbols failed to load.";
            }
            throw new Exception(error);
        }

        const result = SDL_Init(SDL_INIT_EVERYTHING);
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

    void clearError() const @nogc nothrow
    {
        //Move from SdlObject to prevent accidental call and error loss
        SDL_ClearError();
    }

    void quit() const @nogc nothrow
    {
        SDL_Quit();
    }

    void clearHints() const @nogc nothrow
    {
        SDL_ClearHints();
    }

    bool setHint(string name, string value)
    {
        //TODO string loss due to garbage collector?
        SDL_bool isSet = SDL_SetHint(name.toStringz,
            value.toStringz);
        if (const err = getError)
        {
            throw new Exception(err);
        }
        return toBool(isSet);
    }
}
