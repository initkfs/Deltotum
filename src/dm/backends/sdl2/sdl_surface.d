module dm.backends.sdl2.sdl_surface;

// dfmt off
version(SdlBackend):
// dfmt on

import dm.com.graphics.com_surface : ComSurface;
import dm.com.graphics.com_blend_mode : ComBlendMode;
import dm.com.platforms.results.com_result : ComResult;
import dm.backends.sdl2.base.sdl_object_wrapper : SdlObjectWrapper;
import dm.backends.sdl2.sdl_window : SdlWindow;

import dm.math.shapes.rect2d : Rect2d;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlSurface : SdlObjectWrapper!SDL_Surface, ComSurface
{
    this()
    {
        super();
    }

    this(SDL_Surface* ptr)
    {
        super(ptr);
    }

    ComResult createRGBSurface(double width, double height)
    {
        if (ptr)
        {
            disposePtr;
        }
        //TODO or SDL_BYTEORDER?
        version (BigEndian)
        {
            if (const createErr = createRGBSurface(
                    0,
                    cast(int) width,
                    cast(int) height,
                    32,
                    0x0000FF00,
                    0x00FF0000,
                    0xFF000000,
                    0x000000FF))
            {
                return createErr;
            }
        }

        version (LittleEndian)
        {
            if (const createErr = createRGBSurface(0, cast(int) width, cast(int) height, 32,
                    0x00ff0000,
                    0x0000ff00,
                    0x000000ff,
                    0xff000000))
            {
                return createErr;
            }
        }
        assert(this.ptr);
        return ComResult.success;
    }

    ComResult createRGBSurface(uint flags = 0, int width = 10, int height = 10, int depth = 32,
        uint rmask = 0, uint gmask = 0, uint bmask = 0, uint amask = 0)
    {
        if (ptr)
        {
            disposePtr;
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
            disposePtr;
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

    ComResult loadFromPtr(void* newPtr)
    {
        if (ptr)
        {
            disposePtr;
        }
        this.ptr = cast(SDL_Surface*) newPtr;
        return ComResult.success;
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

    ComResult blit(ComSurface dst, Rect2d dstRect)
    {
        SDL_Rect sdlDstRect = {
            cast(int) dstRect.x, cast(int) dstRect.y, cast(int) dstRect.width, cast(int) dstRect
                .height
        };
        return blitPtr(null, dst, &sdlDstRect);
    }

    ComResult blit(Rect2d srcRect, ComSurface dst, Rect2d dstRect)
    {
        SDL_Rect sdlSrcRect = {
            cast(int) srcRect.x, cast(int) srcRect.y, cast(int) srcRect.width, cast(int) srcRect
                .height
        };

        SDL_Rect sdlDstRect = {
            cast(int) dstRect.x, cast(int) dstRect.y, cast(int) dstRect.width, cast(int) dstRect
                .height
        };
        return blitPtr(&sdlSrcRect, dst, &sdlDstRect);
    }

    //https://discourse.libsdl.org/t/sdl-blitsurface-doesnt-work-in-sdl-2-0/19288/3
    ComResult blitPtr(SDL_Rect* srcRect, ComSurface dst, SDL_Rect* dstRect)
    {
        void* dstPtr;
        //TODO unsafe
        if (const err = dst.nativePtr(dstPtr))
        {
            return err;
        }
        SDL_Surface* sdlDstPtr = cast(SDL_Surface*) dstPtr;
        assert(sdlDstPtr);
        
        //TODO check is locked
        const int zeroOrErrorCode = SDL_BlitSurface(ptr, srcRect, sdlDstPtr, dstRect);
        return ComResult(zeroOrErrorCode);
    }

    ComResult blitPtr(SDL_Rect* srcRect, SDL_Surface* dst, SDL_Rect* dstRect)
    {
        const int zeroOrErrorCode = SDL_BlitSurface(ptr, srcRect, dst, dstRect);
        return ComResult(zeroOrErrorCode);
    }

    ComResult getBlitAlphaMod(out int mod)
    {
        ubyte oldMod;
        const int zeroOrErrorCode = SDL_GetSurfaceAlphaMod(ptr, &oldMod);
        if (zeroOrErrorCode == 0)
        {
            mod = oldMod;
            return ComResult.success;
        }
        return ComResult.error("Error change alpha blit mode");
    }

    ComResult setBlitAlhpaMod(int alpha)
    {
        //srcA = srcA * (alpha / 255)
        const int zeroOrErrorCode = SDL_SetSurfaceAlphaMod(ptr, cast(ubyte) alpha);
        return ComResult(zeroOrErrorCode);
    }

    ComResult setBlendMode(ComBlendMode mode)
    {
        const int zeroOrErrorCode = SDL_SetSurfaceBlendMode(ptr, typeConverter.toNativeBlendMode(
                mode));
        return ComResult(zeroOrErrorCode);
    }

    ComResult getBlendMode(out ComBlendMode mode)
    {
        SDL_BlendMode sdlMode;
        const int zeroOrErrorCode = SDL_GetSurfaceBlendMode(ptr, &sdlMode);
        if (zeroOrErrorCode == 0)
        {
            mode = typeConverter.fromNativeBlendMode(sdlMode);
            return ComResult.success;
        }
        return ComResult(zeroOrErrorCode);
    }

    ComResult setPixelIsTransparent(bool isTransparent, ubyte r, ubyte g, ubyte b, ubyte a)
    {
        const colorKey = isTransparent ? SDL_TRUE : SDL_FALSE;
        const int zeroOrErrorCode = SDL_SetColorKey(ptr, colorKey, SDL_MapRGBA(
                ptr.format, r, g, b, a));
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

    uint* getPixel(int x, int y)
    {
        //TODO check bounds
        uint* pixelPtr = cast(Uint32*)(
            cast(
                Uint8*) ptr.pixels + y * ptr.pitch + x * ptr.format.BytesPerPixel);
        return pixelPtr;
    }

    void setPixelRGBA(int x, int y, ubyte r, ubyte g, ubyte b, ubyte a)
    {
        uint* pixelPtr = getPixel(x, y);
        setPixelRGBA(pixelPtr, r, g, b, a);
    }

    void getPixelRGBA(uint* pixel, out ubyte r, out ubyte g, out ubyte b, out ubyte a)
    {
        SDL_GetRGBA(*pixel, ptr.format, &r, &g, &b, &a);
    }

    void setPixelRGBA(uint* pixel, ubyte r, ubyte g, ubyte b, ubyte a)
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

    ComResult nativePtr(out void* nptr) nothrow
    {
        assert(this.ptr);
        nptr = cast(void*) ptr;
        return ComResult.success;
    }

    override protected bool disposePtr() @nogc nothrow
    {
        if (ptr)
        {
            SDL_FreeSurface(ptr);
            return true;
        }
        return false;
    }
}
