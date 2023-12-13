module dm.backs.sdl2.sdl_screen;

// dfmt off
version(SdlBackend):
// dfmt on

import dm.com.graphics.com_screen : ComScreen, ScreenMode, ScreenOrientation, ScreenDpi;
import dm.com.platforms.results.com_result : ComResult;
import dm.backs.sdl2.base.sdl_object : SdlObject;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SDLScreen : SdlObject, ComScreen
{
    ComResult getCount(out size_t count) @nogc nothrow
    {
        const int screenCountOrNegErr = SDL_GetNumVideoDisplays();
        if (screenCountOrNegErr < 0)
        {
            return ComResult.error(getError);
        }

        count = screenCountOrNegErr;

        return ComResult.success;
    }

    ComResult getBounds(int index, out int x, out int y,
        out int width, out int height) @nogc nothrow
    {
        SDL_Rect bounds;
        const zeroOrErrorCode = SDL_GetDisplayBounds(index, &bounds);
        if (zeroOrErrorCode != 0)
        {
            return ComResult(zeroOrErrorCode, getError);
        }

        x = bounds.x;
        y = bounds.y;
        width = bounds.w;
        height = bounds.h;
        return ComResult.success;
    }

    ComResult getUsableBounds(int index, out int x, out int y,
        out int width, out int height) @nogc nothrow
    {
        SDL_Rect bounds;
        const zeroOrErrorCode = SDL_GetDisplayUsableBounds(index, &bounds);
        if (zeroOrErrorCode != 0)
        {
            return ComResult(zeroOrErrorCode, getError);
        }

        x = bounds.x;
        y = bounds.y;
        width = bounds.w;
        height = bounds.h;
        return ComResult.success;
    }

    ComResult getName(int index, ref const(char)* name) @nogc nothrow
    {
        const namePtr = SDL_GetDisplayName(index);
        if (!namePtr)
        {
            return ComResult.error(getError);
        }
        name = namePtr;
        return ComResult.success;
    }

    ComResult getMode(int index, out ScreenMode mode) @nogc nothrow
    {
        SDL_DisplayMode m;
        const zeroOrError = SDL_GetCurrentDisplayMode(index, &m);
        if (zeroOrError != 0)
        {
            return ComResult.error(getError);
        }
        mode = ScreenMode(m.w, m.h, m.refresh_rate);
        return ComResult.success;
    }

    ComResult getDPI(int index, out ScreenDpi screenDPI) @nogc nothrow
    {
        ScreenDpi dpi;
        float diagDpi, horizDpi, vertDpi;
        const zeroOrError = SDL_GetDisplayDPI(index, &diagDpi, &horizDpi, &vertDpi);
        if (zeroOrError != 0)
        {
            return ComResult.error(getError);
        }
        dpi = ScreenDpi(diagDpi, horizDpi, vertDpi);
        screenDPI = dpi;
        return ComResult.success;
    }

    ComResult getOrientation(int index, out ScreenOrientation result) @nogc nothrow
    {
        const orientation = SDL_GetDisplayOrientation(index);
        final switch (orientation) with (SDL_DisplayOrientation)
        {
            case SDL_ORIENTATION_UNKNOWN:
                result = ScreenOrientation.none;
                break;
            case SDL_ORIENTATION_LANDSCAPE:
                result = ScreenOrientation.landscape;
                break;
            case SDL_ORIENTATION_LANDSCAPE_FLIPPED:
                result = ScreenOrientation.landscapeFlipped;
                break;
            case SDL_ORIENTATION_PORTRAIT:
                result = ScreenOrientation.portrait;
                break;
            case SDL_ORIENTATION_PORTRAIT_FLIPPED:
                result = ScreenOrientation.portraitFlipped;
                break;
        }

        return ComResult.success;
    }

    bool isDisposed() @nogc nothrow pure @safe
    {
        return false;
    }

    bool dispose()
    {
        return false;
    }
}
