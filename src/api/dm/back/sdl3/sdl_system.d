module api.dm.back.sdl3.sdl_system;

// dfmt off
version(SdlBackend):
// dfmt on
import api.dm.back.sdl3.base.sdl_object : SdlObject;
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

        if (!SDL_OpenURL(link.toStringz))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult addTimerMT(out int timerId, uint intervalMs, RetNextIntervalCallback callback, void* param)
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
        if (!SDL_RemoveTimer(timerId))
        {
            return getErrorRes("Timer not removed");
        }
        return ComResult.success;
    }

}
