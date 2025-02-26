module api.dm.back.sdl3.sdl_lib;

// dfmt off
version(SdlBackend):
// dfmt on

import std.string : toStringz, fromStringz;

import api.dm.back.sdl3.externs.csdl3;

import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.back.sdl3.base.sdl_object : SdlObject;

/**
 * Authors: initkfs
 */
class SdlLib : SdlObject
{
    ComResult initialize(uint flags) nothrow
    {
        if (!SDL_Init(flags))
        {
            import std.conv : text;

            return ComResult.error(text("Unable to initialize SDL: ", getError));
        }
        return ComResult.success;
    }

    SDL_InitFlags isInit(SDL_InitFlags flags) nothrow => SDL_WasInit(flags);

    ComResult quit() nothrow
    {
        SDL_Quit();
        
        return ComResult.success;
    }

    string stringFromVersion(int ver) nothrow
    {
        import std.conv : text;

        auto major = SDL_VERSIONNUM_MAJOR(ver);
        int minor = SDL_VERSIONNUM_MINOR(ver);
        int patch = SDL_VERSIONNUM_MICRO(ver);

        //format is not nothrow
        immutable sep = ".";
        return text(major, sep, minor, sep, patch);
    }

    alias versionString = linkedVersionString;

    string linkedVersionString() nothrow => stringFromVersion(SDL_GetVersion());

    /** 
     * SDL_timer.h
     */

    ulong ticksMs() nothrow => SDL_GetTicks();
    ulong ticksNs() nothrow => SDL_GetTicksNS();

    void delayMs(uint ms)
    {
        SDL_Delay(ms);
    }

    void delayNs(ulong ms)
    {
        SDL_DelayNS(ms);
    }

    /** 
     * SDL_hints.h
     */

    ComResult getHint(string name, out string value) nothrow
    {
        const(char)* hintPtr = SDL_GetHint(name.toStringz);
        if (!hintPtr)
        {
            import std.conv : text;

            return getErrorRes(text("Error of obtaining a hint with name ", name));
        }

        value = hintPtr.fromStringz.idup;
        return ComResult.success;
    }

    void clearHints() nothrow
    {
        SDL_ResetHints();
    }

    ComResult setHint(string name, string value) nothrow
    {
        import std.string : toStringz;

        return setHint(name.toStringz, value.toStringz);
    }

    ComResult setHint(const(char*) name, string value) nothrow
    {
        import std.string : toStringz;

        return setHint(name, value.toStringz);
    }

    ComResult setHint(const(char*) name, const(char*) value) nothrow
    {
        //TODO string loss due to garbage collector?
        if (!SDL_SetHint(name, value))
        {
            import std.conv : text;
            import std.string : fromStringz;

            return getErrorRes(text("Error setting hint with name ", name.fromStringz.idup, " value ", value
                    .fromStringz.idup, ". "));
        }

        return ComResult.success;
    }

    /** 
     * SDL_video.h
     */

    ComResult setEnableScreenSaver(bool isEnable = true) nothrow
    {
        if (isEnable)
        {
            if (!SDL_EnableScreenSaver())
            {
                return getErrorRes("Error enabling screensaver");
            }

            return ComResult.success;
        }

        if (!SDL_DisableScreenSaver())
        {
            return getErrorRes("Error disabling screensaver");
        }
        return ComResult.success;
    }

    bool isScreenSaverEnabled() nothrow
    {
        auto isEnabled = SDL_ScreenSaverEnabled();
        return isEnabled;
    }
}
