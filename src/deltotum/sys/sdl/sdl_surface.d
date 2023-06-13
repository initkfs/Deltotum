module deltotum.sys.sdl.sdl_surface;

// dfmt off
version(SdlBackend):
// dfmt on

import deltotum.com.platforms.results.com_result : ComResult;
import deltotum.sys.sdl.base.sdl_object_wrapper : SdlObjectWrapper;
import deltotum.sys.sdl.sdl_window : SdlWindow;

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

    ComResult createRGBSurface(uint flags = 0, int width = 10, int height = 10, int depth = 32,
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
            return ComResult.error(error);
        }
        return ComResult.success;
    }

    ComResult createRGBSurfaceFrom(void* pixels, int width, int height, int depth, int pitch,
        uint rmask, uint gmask, uint bmask, uint amask)
    {
        if (ptr)
        {
            destroyPtr;
        }
        ptr = SDL_CreateRGBSurfaceFrom(pixels, width, height, depth, pitch, rmask, gmask, bmask, amask);
        if (!ptr)
        {
            string error = "Cannot create rgb surface from pixels.";
            if (const err = getError)
            {
                error ~= err;
            }
            return ComResult.error(error);
        }
        return ComResult.success;
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

    ComResult convertSurfacePtr(SDL_Surface* src, out SDL_Surface* dest, SDL_PixelFormat* format, uint flags = 0) const
    {
        SDL_Surface* ptr = SDL_ConvertSurface(src, format, flags);
        if (!ptr)
        {
            string errMessage = "New surface сonverted pointer is null.";
            if (const err = getError)
            {
                errMessage ~= err;
            }
            return ComResult.error(errMessage);
        }
        dest = ptr;
        return ComResult.success;
    }

    protected ComResult scaleToPtr(SDL_Surface* destPtr, SDL_Rect* bounds) @nogc nothrow
    {
        const int zeroOrErrorCode = SDL_BlitScaled(ptr, null, destPtr, bounds);
        return ComResult(zeroOrErrorCode);
    }

    ComResult scaleTo(SdlSurface dest, SDL_Rect* bounds) @nogc nothrow
    {
        return scaleToPtr(dest.getObject, bounds);
    }

    ComResult resize(int newWidth, int newHeight, out bool isResized)
    {
        //https://stackoverflow.com/questions/40850196/sdl2-resize-a-surface
        // https://stackoverflow.com/questions/33850453/sdl2-blit-scaled-from-a-palettized-8bpp-surface-gives-error-blit-combination/33944312
        if (newWidth <= 0 || newHeight <= 0)
        {
            return ComResult.success;
        }

        int w = width;
        int h = height;

        if (w == newWidth && h == newHeight)
        {
            return ComResult.success;
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
            return ComResult.error(error);
        }

        if (const err = scaleToPtr(newSurfacePtr, &dest))
        {
            return err;
        }

        updateObject(newSurfacePtr);
        isResized = true;
        return ComResult.success;
    }

    ComResult blit(const SDL_Rect* srcRect, SDL_Surface* dst, SDL_Rect* dstRect)
    {
        const int zeroOrErrorCode = SDL_BlitSurface(ptr, srcRect, dst, dstRect);
        return ComResult(zeroOrErrorCode);
    }

    ComResult lock()
    {
        assert(ptr);
        const int zeroOrErrorCode = SDL_LockSurface(ptr);
        return ComResult(zeroOrErrorCode);
    }

    ComResult unlock()
    {
        assert(ptr);
        SDL_UnlockSurface(ptr);
        return ComResult.success;
    }

    inout(void*) pixels() inout @nogc nothrow @safe
    {
        return ptr.pixels;
    }

    uint* pixel(int x, int y)
    {
        uint* pixelPos = cast(Uint32*)(
            cast(
                Uint8*) ptr.pixels + y * ptr.pitch + x * ptr.format.BytesPerPixel);
        return pixelPos;
    }

    void setPixel(int x, int y, ubyte r, ubyte g, ubyte b, ubyte a)
    {
        uint* pixelPtr = pixel(x, y);
        setPixel(pixelPtr, r, g, b, a);
    }

    void setPixel(uint* pixel, ubyte r, ubyte g, ubyte b, ubyte a)
    {
        Uint32 color = SDL_MapRGBA(ptr.format, r, g, b, a);
        *pixel = color;
    }

    int pitch() inout @nogc nothrow @safe
    {
        return ptr.pitch;
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
    in (ptr !is null)
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
