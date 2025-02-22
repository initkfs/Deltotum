module api.dm.back.sdl3.sdl_screen;

// dfmt off
version(SdlBackend):
// dfmt on

import api.dm.com.graphics.com_screen : ComScreen, ComScreenMode, ComScreenOrientation, ComScreenDpi;
import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.back.sdl3.base.sdl_object : SdlObject;

import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */
class SDLScreen : SdlObject, ComScreen
{
    ComResult getCount(out size_t count) nothrow
    {
        int dcount;
        SDL_DisplayID* displays = SDL_GetDisplays(&dcount);
        
        if (!displays)
        {
            return getErrorRes;
        }

        count = dcount;

        return ComResult.success;
    }

    ComResult getBounds(int index, out int x, out int y,
        out int width, out int height) nothrow
    {
        SDL_Rect bounds;
        if (!SDL_GetDisplayBounds(index, &bounds))
        {
            return getErrorRes;
        }

        x = bounds.x;
        y = bounds.y;
        width = bounds.w;
        height = bounds.h;
        return ComResult.success;
    }

    ComResult getUsableBounds(int index, out int x, out int y,
        out int width, out int height) nothrow
    {
        SDL_Rect bounds;
        if (!SDL_GetDisplayUsableBounds(index, &bounds))
        {
            return getErrorRes;
        }

        x = bounds.x;
        y = bounds.y;
        width = bounds.w;
        height = bounds.h;
        return ComResult.success;
    }

    ComResult getName(int index, out dstring name) nothrow
    {
        const namePtr = SDL_GetDisplayName(index);
        if (!namePtr)
        {
            return getErrorRes("Screen name not found");
        }
        import std.conv : to;

        try
        {
            name = namePtr.to!dstring;
        }
        catch (Exception e)
        {
            return ComResult.error(e.msg);
        }
        return ComResult.success;
    }

    ComResult getMode(int index, out ComScreenMode mode) nothrow
    {
        SDL_DisplayMode* screenMode = SDL_GetCurrentDisplayMode(index);
        if (!screenMode)
        {
            return getErrorRes;
        }

        mode = ComScreenMode(screenMode.w, screenMode.h, screenMode.refresh_rate);
        return ComResult.success;
    }

    ComResult getOrientation(int index, out ComScreenOrientation result) nothrow
    {
        const orientation = SDL_GetCurrentDisplayOrientation(index);
        final switch (orientation)
        {
            case SDL_ORIENTATION_UNKNOWN:
                result = ComScreenOrientation.none;
                break;
            case SDL_ORIENTATION_LANDSCAPE:
                result = ComScreenOrientation.landscape;
                break;
            case SDL_ORIENTATION_LANDSCAPE_FLIPPED:
                result = ComScreenOrientation.landscapeFlipped;
                break;
            case SDL_ORIENTATION_PORTRAIT:
                result = ComScreenOrientation.portrait;
                break;
            case SDL_ORIENTATION_PORTRAIT_FLIPPED:
                result = ComScreenOrientation.portraitFlipped;
                break;
        }

        return ComResult.success;
    }

    bool isDisposed() nothrow pure @safe
    {
        return false;
    }

    bool dispose()
    {
        return false;
    }
}
