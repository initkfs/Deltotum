module deltotum.hal.sdl.sdl_surface;

import deltotum.hal.sdl.base.sdl_object_wrapper : SdlObjectWrapper;
import deltotum.hal.sdl.sdl_window : SdlWindow;

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

    void createRGBSurface(uint flags, int width, int height, int depth,
        uint rmask, uint gmask, uint bmask, uint amask)
    {
        ptr = createRGBSurfacePtr(flags, width, height, depth, rmask, gmask, bmask, amask);
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
        if (!newPtr)
        {
            string error = "Cannot create rgb surface.";
            if (const err = getError)
            {
                error ~= err;
            }
            throw new Exception(error);
        }
        return newPtr;
    }

    static SdlSurface getWindowSurface(SdlWindow window)
    {
        SDL_Surface* ptr = SDL_GetWindowSurface(window.getSdlObject);
        return new SdlSurface(ptr);
    }

    SDL_Surface* convertSurfacePtr(SDL_Surface* src, SDL_PixelFormat* format, uint flags = 0) const @nogc nothrow
    {
        SDL_Surface* ptr = SDL_ConvertSurface(src, format, flags);
        return ptr;
    }

    protected void scaleToPtr(SDL_Surface* destPtr, SDL_Rect* bounds) @nogc nothrow
    {
        SDL_BlitScaled(ptr, null, destPtr, bounds);
    }

    void scaleTo(SdlSurface dest, SDL_Rect* bounds) @nogc nothrow
    {
        scaleToPtr(dest.getSdlObject, bounds);
    }

    bool resize(int newWidth, int newHeight)
    {
        //https://stackoverflow.com/questions/40850196/sdl2-resize-a-surface
        // https://stackoverflow.com/questions/33850453/sdl2-blit-scaled-from-a-palettized-8bpp-surface-gives-error-blit-combination/33944312
        if (newWidth <= 0 || newHeight <= 0)
        {
            return false;
        }

        int w = width;
        int h = height;

        if (w == newWidth && h == newHeight)
        {
            return false;
        }

        SDL_Rect dest;
        dest.x = 0;
        dest.y = 0;
        dest.w = newWidth;
        dest.h = newHeight;

        auto newSurfacePtr = createRGBSurfacePtr(getSdlObject.flags, dest.w, dest.h,
            getPixelFormat.BitsPerPixel, getPixelFormat.Rmask,
            getPixelFormat.Gmask, getPixelFormat.Bmask, getPixelFormat.Amask);

        scaleToPtr(newSurfacePtr, &dest);
        destroyPtr(ptr);
        ptr = newSurfacePtr;
        return true;
    }

    SDL_PixelFormat* getPixelFormat() @nogc nothrow @safe
    {
        return ptr.format;
    }

    int width() @nogc nothrow @safe
    {
        return ptr.w;
    }

    int height() @nogc nothrow @safe
    {
        return ptr.h;
    }

    void destroyPtr(SDL_Surface* ptr) @nogc nothrow
    {
        SDL_FreeSurface(ptr);
    }

    override void destroy() @nogc nothrow
    {
        destroyPtr(ptr);
    }
}
