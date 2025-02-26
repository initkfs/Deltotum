module api.dm.back.sdl3.sdl_screen;

import api.dm.com.platforms.results.com_result;

// dfmt off
version(SdlBackend):
// dfmt on

import api.dm.com.graphics.com_screen : ComScreenId, ComScreen, ComScreenMode, ComScreenOrientation, ComScreenDpi;
import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.com.graphics.com_window : ComWindow;
import api.dm.back.sdl3.base.sdl_object : SdlObject;

import api.math.geom2.rect2 : Rect2d;

import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */
class SDLScreen : SdlObject, ComScreen
{
    ComResult onScreens(scope bool delegate(ComScreenId) nothrow onScreenIdIsContinue) nothrow
    {
        int count;
        SDL_DisplayID* displays = SDL_GetDisplays(&count);
        if (!displays)
        {
            return getErrorRes("Error getting screens array");
        }

        foreach (i; 0 .. count)
        {
            SDL_DisplayID id = displays[i];
            if (!onScreenIdIsContinue(id))
            {
                break;
            }
        }
        return ComResult.success;
    }

    ComResult getScreenForWindow(ComWindow window, out ComScreenId id) nothrow
    {
        import api.dm.com.com_native_ptr : ComNativePtr;

        ComNativePtr winPtr;
        if (const err = window.nativePtr(winPtr))
        {
            return err;
        }

        SDL_Window* ptr = winPtr.castSafe!(SDL_Window*);

        SDL_DisplayID sdlId;
        if (const err = getScreenForWindow(ptr, sdlId))
        {
            return err;
        }
        id = sdlId;
        return ComResult.success;
    }

    ComResult getScreenForWindow(SDL_Window* window, out SDL_DisplayID id) nothrow
    {
        auto newId = SDL_GetDisplayForWindow(window);
        if (newId == 0)
        {
            return getErrorRes("Error getting display for window");
        }
        id = newId;
        return ComResult.success;
    }

    ComResult getBounds(ComScreenId id, out int x, out int y,
        out int width, out int height) nothrow
    {
        SDL_Rect bounds;
        if (!SDL_GetDisplayBounds(id, &bounds))
        {
            return getErrorRes("Error getting display bounds");
        }

        x = bounds.x;
        y = bounds.y;
        width = bounds.w;
        height = bounds.h;
        return ComResult.success;
    }

    ComResult getUsableBounds(ComScreenId id, out int x, out int y,
        out int width, out int height) nothrow
    {
        SDL_Rect bounds;
        if (!SDL_GetDisplayUsableBounds(id, &bounds))
        {
            return getErrorRes("Error getting display usable bounds");
        }

        x = bounds.x;
        y = bounds.y;
        width = bounds.w;
        height = bounds.h;
        return ComResult.success;
    }

    ComResult getName(ComScreenId id, out string name) nothrow
    {
        const namePtr = SDL_GetDisplayName(id);
        if (!namePtr)
        {
            return getErrorRes("Error getting display name");
        }

        import std.string : fromStringz;

        name = namePtr.fromStringz.idup;
        return ComResult.success;
    }

    ComResult getVideoDriverName(out string name) nothrow
    {
        const char* namePtr = SDL_GetCurrentVideoDriver();
        if (!namePtr)
        {
            name = "null";
            return ComResult.success;
        }

        import std.string : fromStringz;

        name = namePtr.fromStringz.idup;
        return ComResult.success;
    }

    ComResult getMode(ComScreenId id, out ComScreenMode mode) nothrow
    {
        SDL_DisplayMode* screenMode = SDL_GetCurrentDisplayMode(id);
        if (!screenMode)
        {
            return getErrorRes("Error getting screen mode");
        }

        mode = ComScreenMode(id, screenMode.w, screenMode.h, screenMode.refresh_rate, screenMode
                .pixel_density);
        return ComResult.success;
    }

    ComResult getOrientation(ComScreenId id, out ComScreenOrientation result) nothrow
    {
        const orientation = SDL_GetCurrentDisplayOrientation(id);
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
