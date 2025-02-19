module api.dm.back.sdl2.sdl_system;

// dfmt off
version(SdlBackend):
// dfmt on
import api.dm.back.sdl2.base.sdl_object : SdlObject;
import api.dm.com.platforms.com_system : ComSystem, RetNextIntervalCallback;
import api.dm.com.platforms.results.com_result : ComResult;

import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */
class SDLSystem : SdlObject, ComSystem
{
    ComResult openURL(string link) nothrow
    {
        import std.string : toStringz;

        if (link.length == 0)
        {
            return ComResult.error("URL must not be empty");
        }

        const zeroOrNegErr = SDL_OpenURL(link.toStringz);
        if (zeroOrNegErr != 0)
        {
            return getErrorRes(zeroOrNegErr);
        }
        return ComResult.success;
    }

    ComResult addTimerMT(out int timerId, int intervalMs, RetNextIntervalCallback callback, void* param)
    {
        const timerIdOrZeroErr = SDL_AddTimer(intervalMs, callback, param);
        if (timerIdOrZeroErr == 0)
        {
            return getErrorRes("Error adding timer");
        }
        timerId = timerIdOrZeroErr;
        return ComResult.success;
    }

    ComResult removeTimer(int timerId)
    {
        SDL_bool isRemove = SDL_RemoveTimer(timerId);
        if (isRemove == SDL_bool.SDL_FALSE)
        {
            return getErrorRes("Timer not removed");
        }
        return ComResult.success;
    }

}
