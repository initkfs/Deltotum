module deltotum.platform.sdl.sdl_surface;

import deltotum.platform.result.platform_result : PlatformResult;
import deltotum.platform.sdl.base.sdl_object_wrapper : SdlObjectWrapper;
import deltotum.platform.sdl.sdl_window : SdlWindow;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlSurface : SdlObjectWrapper!SDL_Surface
{
    this()
    {
        super();
    }

    this(SDL_Surface* ptr)
    {
        super(ptr);
    }

    PlatformResult createRGBSurface(uint flags = 0, int width = 10, int height = 10, int depth = 32,
        uint rmask = 0, uint gmask = 0, uint bmask = 0, uint amask = 0)
    {
        if (ptr)
        {
            destroyPtr;
        }
        ptr = createRGBSurfacePtr(flags, width, height, depth, rmask, gmask, bmask, amask);
        if (!ptr)
        {
            string error = "Cannot create rgb surface.";
            if (const err = getError)
            {
                error ~= err;
            }
            return PlatformResult.error(error);
        }
        return PlatformResult.success;
    }

    SDL_Surface* createRGBSurfacePtr(uint flags, int width, int height, int depth,
        uint rmask, uint gmask, uint bmask, uint amask)
    {
        auto newPtr = SDL_CreateRGBSurface(
            flags,
            width,
            height,
            depth,
            rmask,
            gmask,
            bmask,
            amask);
        return newPtr;
    }

    static SdlSurface getWindowSurface(SdlWindow window)
    {
        SDL_Surface* ptr = SDL_GetWindowSurface(window.getObject);
        if (!ptr)
        {
            throw new Exception("New surface pointer is null.");
        }
        return new SdlSurface(ptr);
    }

    PlatformResult convertSurfacePtr(SDL_Surface* src, out SDL_Surface* dest, SDL_PixelFormat* format, uint flags = 0) const
    {
        SDL_Surface* ptr = SDL_ConvertSurface(src, format, flags);
        if (!ptr)
        {
            string errMessage = "New surface сonverted pointer is null.";
            if (const err = getError)
            {
                errMessage ~= err;
            }
            return PlatformResult.error(errMessage);
        }
        dest = ptr;
        return PlatformResult.success;
    }

    protected PlatformResult scaleToPtr(SDL_Surface* destPtr, SDL_Rect* bounds) @nogc nothrow
    {
        const int zeroOrErrorCode = SDL_BlitScaled(ptr, null, destPtr, bounds);
        return PlatformResult(zeroOrErrorCode);
    }

    PlatformResult scaleTo(SdlSurface dest, SDL_Rect* bounds) @nogc nothrow
    {
        return scaleToPtr(dest.getObject, bounds);
    }

    PlatformResult resize(int newWidth, int newHeight, out bool isResized)
    {
        //https://stackoverflow.com/questions/40850196/sdl2-resize-a-surface
        // https://stackoverflow.com/questions/33850453/sdl2-blit-scaled-from-a-palettized-8bpp-surface-gives-error-blit-combination/33944312
        if (newWidth <= 0 || newHeight <= 0)
        {
            return PlatformResult.success;
        }

        int w = width;
        int h = height;

        if (w == newWidth && h == newHeight)
        {
            return PlatformResult.success;
        }

        SDL_Rect dest;
        dest.x = 0;
        dest.y = 0;
        dest.w = newWidth;
        dest.h = newHeight;

        auto newSurfacePtr = createRGBSurfacePtr(getObject.flags, dest.w, dest.h,
            getPixelFormat.BitsPerPixel, getPixelFormat.Rmask,
            getPixelFormat.Gmask, getPixelFormat.Bmask, getPixelFormat.Amask);

        if (!newSurfacePtr)
        {
            string error = "Resizing error: new surface pointer is null";
            if (const err = getError)
            {
                error ~= err;
            }
            return PlatformResult.error(error);
        }

        if (const err = scaleToPtr(newSurfacePtr, &dest))
        {
            return err;
        }

        updateObject(newSurfacePtr);
        isResized = true;
        return PlatformResult.success;
    }

    PlatformResult blit(const SDL_Rect* srcRect, SDL_Surface* dst, SDL_Rect* dstRect)
    {
        const int zeroOrErrorCode = SDL_BlitSurface(ptr, srcRect, dst, dstRect);
        return PlatformResult(zeroOrErrorCode);
    }

    inout(SDL_PixelFormat*) getPixelFormat() inout @nogc nothrow @safe
    in (ptr !is null)
    {
        return ptr.format;
    }

    int width() @nogc nothrow @safe
    in (ptr !is null)
    {
        return ptr.w;
    }

    int height() @nogc nothrow @safe
    in(ptr !is null)
    {
        return ptr.h;
    }

    override protected bool destroyPtr() @nogc nothrow
    {
        if (ptr)
        {
            SDL_FreeSurface(ptr);
            return true;
        }
        return false;
    }
}
