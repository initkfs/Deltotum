module api.dm.back.sdl2.sdl_screen;

// dfmt off
version(SdlBackend):
// dfmt on

import api.dm.com.graphics.com_screen : ComScreen, ComScreenMode, ComScreenOrientation, ComScreenDpi;
import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.back.sdl2.base.sdl_object : SdlObject;

import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */
class SDLScreen : SdlObject, ComScreen
{
    ComResult getCount(out size_t count) nothrow
    {
        const int screenCountOrNegErr = SDL_GetNumVideoDisplays();
        if (screenCountOrNegErr < 0)
        {
            return getErrorRes(screenCountOrNegErr);
        }

        count = screenCountOrNegErr;

        return ComResult.success;
    }

    ComResult getBounds(int index, out int x, out int y,
        out int width, out int height) nothrow
    {
        SDL_Rect bounds;
        const zeroOrErrorCode = SDL_GetDisplayBounds(index, &bounds);
        if (zeroOrErrorCode)
        {
            return getErrorRes(zeroOrErrorCode);
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
        const zeroOrErrorCode = SDL_GetDisplayUsableBounds(index, &bounds);
        if (zeroOrErrorCode)
        {
            return getErrorRes(zeroOrErrorCode);
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
        SDL_DisplayMode m;
        const zeroOrError = SDL_GetCurrentDisplayMode(index, &m);
        if (zeroOrError != 0)
        {
            return getErrorRes(zeroOrError);
        }
        mode = ComScreenMode(m.w, m.h, m.refresh_rate);
        return ComResult.success;
    }

    ComResult getDPI(int index, out ComScreenDpi screenDPI) nothrow
    {
        ComScreenDpi dpi;
        float diagDpi, horizDpi, vertDpi;
        const zeroOrError = SDL_GetDisplayDPI(index, &diagDpi, &horizDpi, &vertDpi);
        if (zeroOrError != 0)
        {
            return getErrorRes(zeroOrError);
        }
        dpi = ComScreenDpi(diagDpi, horizDpi, vertDpi);
        screenDPI = dpi;
        return ComResult.success;
    }

    ComResult getOrientation(int index, out ComScreenOrientation result) nothrow
    {
        const orientation = SDL_GetDisplayOrientation(index);
        final switch (orientation) with (SDL_DisplayOrientation)
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
