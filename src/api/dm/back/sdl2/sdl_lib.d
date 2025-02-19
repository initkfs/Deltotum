module api.dm.back.sdl2.sdl_lib;

// dfmt off
version(SdlBackend):
// dfmt on

import std.string : toStringz, fromStringz;

import api.dm.back.sdl3.externs.csdl3;
import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.back.sdl2.base.sdl_object : SdlObject;

/**
 * Authors: initkfs
 */
class SdlLib : SdlObject
{
    void initialize(uint flags) const
    {
        if (!SDL_Init(flags))
        {
            string initError = "Unable to initialize sdl subsystems.";
            if (auto error = getError)
            {
                initError ~= error;
            }

            throw new Exception(initError);
        }
    }

    ulong getTicks()
    {
        return SDL_GetTicks();
    }

    void delay(uint ms)
    {
        SDL_Delay(ms);
    }

    SDL_InitFlags wasInit(SDL_InitFlags flags) const nothrow
    {
        return SDL_WasInit(flags);
    }

    void quit() const nothrow
    {
        SDL_Quit();
    }

    ComResult enableScreenSaver(bool isEnable = true) const nothrow
    {
        if (isEnable)
        {
            if (!SDL_EnableScreenSaver())
            {
                return getErrorRes;
            }
            return ComResult.success;
        }

        if (!SDL_DisableScreenSaver())
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    bool isScreenSaverEnabled() const nothrow
    {
        auto isEnabled = SDL_ScreenSaverEnabled();
        return typeConverter.toBool(isEnabled);
    }

    string getSdlVersionInfo() const nothrow
    {
        import std.conv : text;

        int ver = SDL_GetVersion();
        int major, minor, patch;

        SDL_VERSIONNUM(major, minor, patch);

        //format is not nothrow
        return text(major, ".", minor, ".", patch);
    }

    string getHint(string name) const nothrow
    {
        const(char)* hintPtr = SDL_GetHint(name.toStringz);
        if (hintPtr is null)
        {
            return null;
        }
        immutable hintValue = hintPtr.fromStringz.idup;
        return hintValue;
    }

    void clearHints() const nothrow
    {
        SDL_ResetHints();
    }

    bool setHint(string name, string value) const nothrow
    {
        import std.string : toStringz;

        //TODO string loss due to garbage collector?
        sdlbool isSet = SDL_SetHint(name.toStringz,
            value.toStringz);
        return typeConverter.toBool(isSet);
    }
}
