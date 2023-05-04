module deltotum.sys.sdl.sdl_screen;

// dfmt off
version(SdlBackend):
// dfmt on

import deltotum.com.platforms.results.com_result : ComResult;
import deltotum.sys.sdl.base.sdl_object : SdlObject;

import bindbc.sdl;

enum SDLScreenOrientation
{
    none,
    landscape,
    landscapeFlipped,
    portrait,
    portraitFlipped
}

struct SDLScreenMode
{
    int width;
    int height;
    int rateHz;
}

struct SDLDpi
{
    float diagonalDPI;
    float horizontalDPI;
    float verticalDPI;
}

/**
 * Authors: initkfs
 */
class SDLScreen : SdlObject
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

    ComResult getName(int index, ref const(char)* name)
    {
        const namePtr = SDL_GetDisplayName(index);
        if (!namePtr)
        {
            return ComResult.error(getError);
        }
        name = namePtr;
        return ComResult.success;
    }

    ComResult getMode(int index, out SDLScreenMode mode)
    {
        SDL_DisplayMode m;
        const zeroOrError = SDL_GetCurrentDisplayMode(index, &m);
        if (zeroOrError != 0)
        {
            return ComResult.error(getError);
        }
        mode = SDLScreenMode(m.w, m.h, m.refresh_rate);
        return ComResult.success;
    }

    ComResult getDPI(int index, out SDLDpi screenDPI)
    {
        SDLDpi dpi;
        const zeroOrError = SDL_GetDisplayDPI(index, &dpi.diagonalDPI, &dpi.horizontalDPI, &dpi
                .verticalDPI);
        if (zeroOrError != 0)
        {
            return ComResult.error(getError);
        }
        screenDPI = dpi;
        return ComResult.success;
    }

    ComResult getOrientation(int index, out SDLScreenOrientation result)
    {
        const orientation = SDL_GetDisplayOrientation(index);
        final switch (orientation) with (SDL_DisplayOrientation)
        {
        case SDL_ORIENTATION_UNKNOWN:
            result = SDLScreenOrientation.none;
            break;
        case SDL_ORIENTATION_LANDSCAPE:
            result = SDLScreenOrientation.landscape;
            break;
        case SDL_ORIENTATION_LANDSCAPE_FLIPPED:
            result = SDLScreenOrientation.landscapeFlipped;
            break;
        case SDL_ORIENTATION_PORTRAIT:
            result = SDLScreenOrientation.portrait;
            break;
        case SDL_ORIENTATION_PORTRAIT_FLIPPED:
            result = SDLScreenOrientation.portraitFlipped;
            break;
        }

        return ComResult.success;
    }
}
