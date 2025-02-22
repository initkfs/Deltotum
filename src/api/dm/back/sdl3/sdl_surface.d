module api.dm.back.sdl3.sdl_surface;

// dfmt off
version(SdlBackend):
// dfmt on

import api.dm.com.com_native_ptr : ComNativePtr;
import api.dm.com.graphics.com_surface : ComSurface;
import api.dm.com.graphics.com_blend_mode : ComBlendMode;
import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.com.com_native_ptr : ComNativePtr;
import api.dm.back.sdl3.base.sdl_object_wrapper : SdlObjectWrapper;
import api.dm.back.sdl3.sdl_window : SdlWindow;

import api.math.geom2.rect2 : Rect2d;
import std.typecons : Tuple;

import api.dm.back.sdl3.externs.csdl3;

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

    ComResult createRGB(int width, int height) nothrow
    {
        if (ptr)
        {
            disposePtr;
        }

        if (const createErr = createRGB(width, height, SDL_PIXELFORMAT_RGBA32))
        {
            return createErr;
        }

        assert(this.ptr);
        return ComResult.success;
    }

    ComResult createRGB(int width, int height, uint format) nothrow
    {
        if (ptr)
        {
            disposePtr;
        }
        ptr = createRGBSurfacePtr(width, height, format);
        if (!ptr)
        {
            return getErrorRes("Cannot create rgb surface");
        }
        return ComResult.success;
    }

    ComResult createRGB(void* pixels, int width, int height, uint format, int pitch) nothrow
    {
        assert(pixels);

        if (ptr)
        {
            disposePtr;
        }
        ptr = SDL_CreateSurfaceFrom(width, height, cast(SDL_PixelFormat) format, pixels, pitch);
        if (!ptr)
        {
            return getErrorRes("Cannot create rgb surface from pixels.");
        }
        return ComResult.success;
    }

    SDL_Surface* createRGBSurfacePtr(int width, int height, uint format) nothrow
    {
        auto newPtr = SDL_CreateSurface(width, height, cast(SDL_PixelFormat) format);
        return newPtr;
    }

    ComResult createFromPtr(void* newPtr) nothrow
    {
        assert(newPtr);
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

    ComResult convertSurfacePtr(SDL_Surface* src, out SDL_Surface* dest, SDL_PixelFormat format) const nothrow
    {
        SDL_Surface* ptr = SDL_ConvertSurface(src, format);
        if (!ptr)
        {
            return getErrorRes("New surface сonverted pointer is null.");
        }
        dest = ptr;
        return ComResult.success;
    }

    protected ComResult scaleToPtr(SDL_Surface* destPtr, SDL_Rect* bounds) nothrow
    {
        SDL_ScaleMode scaleMode = SDL_SCALEMODE_LINEAR;
        if (!SDL_BlitSurfaceScaled(ptr, null, destPtr, bounds, scaleMode))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult scaleTo(SdlSurface dest, SDL_Rect* bounds) nothrow
    {
        return scaleToPtr(dest.getObject, bounds);
    }

    ComResult resize(int newWidth, int newHeight, out bool isResized) nothrow
    {
        //https://stackoverflow.com/questions/40850196/sdl2-resize-a-surface
        // https://stackoverflow.com/questions/33850453/sdl2-blit-scaled-from-a-palettized-8bpp-surface-gives-error-blit-combination/33944312
        if (newWidth <= 0 || newHeight <= 0)
        {
            return ComResult.error("Surface size must be positive values");
        }

        int w, h;
        if (auto err = getWidth(w))
        {
            return err;
        }
        if (auto err = getHeight(h))
        {
            return err;
        }

        if (w == newWidth && h == newHeight)
        {
            return ComResult.success;
        }

        SDL_Rect dest;
        dest.x = 0;
        dest.y = 0;
        dest.w = newWidth;
        dest.h = newHeight;

        auto newSurfacePtr = createRGBSurfacePtr(dest.w, dest.h, getPixelFormat);

        if (!newSurfacePtr)
        {
            return getErrorRes("Resizing error: new surface pointer is null");
        }

        if (const err = scaleToPtr(newSurfacePtr, &dest))
        {
            return err;
        }

        updateObject(newSurfacePtr);
        isResized = true;
        return ComResult.success;
    }

    ComResult blit(ComSurface dst, Rect2d dstRect) nothrow
    {
        SDL_Rect sdlDstRect = {
            cast(int) dstRect.x, cast(int) dstRect.y, cast(int) dstRect.width, cast(int) dstRect
                .height
        };
        return blitPtr(null, dst, &sdlDstRect);
    }

    ComResult blit(Rect2d srcRect, ComSurface dst, Rect2d dstRect) nothrow
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
    ComResult blitPtr(SDL_Rect* srcRect, ComSurface dst, SDL_Rect* dstRect) nothrow
    {
        ComNativePtr dstPtr;
        //TODO unsafe
        if (const err = dst.nativePtr(dstPtr))
        {
            return err;
        }
        SDL_Surface* sdlDstPtr = dstPtr.castSafe!(SDL_Surface*);
        assert(sdlDstPtr);

        //TODO check is locked
        if (!SDL_BlitSurface(ptr, srcRect, sdlDstPtr, dstRect))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult blitPtr(SDL_Rect* srcRect, SDL_Surface* dst, SDL_Rect* dstRect) nothrow
    {
        if (!SDL_BlitSurface(ptr, srcRect, dst, dstRect))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult getBlitAlphaMod(out int mod) nothrow
    {
        ubyte oldMod;
        if (!SDL_GetSurfaceAlphaMod(ptr, &oldMod))
        {
            return getErrorRes;
        }

        mod = oldMod;
        return ComResult.success;
    }

    ComResult setBlitAlhpaMod(int alpha) nothrow
    {
        //srcA = srcA * (alpha / 255)
        if (!SDL_SetSurfaceAlphaMod(ptr, cast(ubyte) alpha))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult setBlendMode(ComBlendMode mode) nothrow
    {
        if (!SDL_SetSurfaceBlendMode(ptr, typeConverter.toNativeBlendMode(mode)))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult getBlendMode(out ComBlendMode mode) nothrow
    {
        SDL_BlendMode sdlMode;
        if (!SDL_GetSurfaceBlendMode(ptr, &sdlMode))
        {
            return getErrorRes;
        }

        mode = typeConverter.fromNativeBlendMode(sdlMode);
        return ComResult.success;
    }

    ComResult setPixelIsTransparent(bool isTransparent, ubyte r, ubyte g, ubyte b, ubyte a) nothrow
    {
        sdlbool colorKey = isTransparent ? true : false;

        auto format = ptr.format;
        SDL_PixelFormatDetails* details;
        SDL_Palette* palette;

        if (const err = getFormatDetails(format, details))
        {
            return err;
        }

        if (const err = getPalette(palette))
        {
            return err;
        }
        assert(details);

        if (!SDL_SetSurfaceColorKey(ptr, colorKey, SDL_MapRGBA(
                details, palette, r, g, b, a)))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    protected ComResult getFormatDetails(SDL_PixelFormat format, out SDL_PixelFormatDetails* details) nothrow
    {
        SDL_PixelFormatDetails* detailsPtr = SDL_GetPixelFormatDetails(format);
        if (!detailsPtr)
        {
            return getErrorRes;
        }
        details = detailsPtr;
        return ComResult.success;
    }

    protected ComResult getPalette(out SDL_Palette* palette) nothrow
    {
        assert(ptr);

        SDL_Palette* palettePtr = SDL_GetSurfacePalette(ptr);
        palette = palettePtr;

        return ComResult.success;
    }

    ComResult lock() nothrow
    {
        assert(ptr);
        //TODO  SDL_MUSTLOCK(surface)
        if (!SDL_LockSurface(ptr))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult unlock() nothrow
    {
        assert(ptr);
        SDL_UnlockSurface(ptr);

        return ComResult.success;
    }

    ComResult getPixels(out void* pixPtr) nothrow
    {
        assert(ptr);
        pixPtr = ptr.pixels;
        return ComResult.success;
    }

    ComResult getPixel(int x, int y, out uint* pixel) nothrow
    {
        assert(ptr);
        //TODO cache
        SDL_PixelFormatDetails* details;
        if (const err = getFormatDetails(ptr.format, details))
        {
            return err;
        }
        //TODO check bounds
        pixel = cast(Uint32*)(
            cast(
                Uint8*) ptr.pixels + y * ptr.pitch + x * details.bytes_per_pixel);
        return ComResult.success;
    }

    ComResult setPixelRGBA(int x, int y, ubyte r, ubyte g, ubyte b, ubyte a) nothrow
    {
        uint* pixelPtr;
        if (auto err = getPixel(x, y, pixelPtr))
        {
            return err;
        }
        return setPixelRGBA(pixelPtr, r, g, b, a);
    }

    ComResult getPixelRGBA(uint* pixel, out ubyte r, out ubyte g, out ubyte b, out ubyte a) nothrow
    {
        SDL_PixelFormatDetails* details;
        if (const err = getFormatDetails(ptr.format, details))
        {
            return err;
        }
        SDL_Palette* palette;
        if (const err = getPalette(palette))
        {
            return err;
        }

        SDL_GetRGBA(*pixel, details,palette,  &r, &g, &b, &a);
        return ComResult.success;
    }

    ComResult setPixelRGBA(uint* pixel, ubyte r, ubyte g, ubyte b, ubyte a) nothrow
    {
        SDL_PixelFormatDetails* details;
        if (const err = getFormatDetails(ptr.format, details))
        {
            return err;
        }
        SDL_Palette* palette;
        if (const err = getPalette(palette))
        {
            return err;
        }

        Uint32 color = SDL_MapRGBA(details, palette, r, g, b, a);
        *pixel = color;
        return ComResult.success;
    }

    ComResult getPixels(scope bool delegate(size_t, size_t, ubyte, ubyte, ubyte, ubyte) onXYRGBAIsContinue)
    {
        int h, w;
        if (auto err = getWidth(w))
        {
            return err;
        }

        if (auto err = getHeight(h))
        {
            return err;
        }
        foreach (y; 0 .. h)
        {
            foreach (x; 0 .. w)
            {
                uint* pixelPtr;
                if (const err = getPixel(x, y, pixelPtr))
                {
                    return err;
                }
                ubyte r, g, b, a;
                if (const err = getPixelRGBA(pixelPtr, r, g, b, a))
                {
                    return err;
                }
                if (!onXYRGBAIsContinue(x, y, r, g, b, a))
                {
                    return ComResult.success;
                }
            }
        }
        return ComResult.success;
    }

    ComResult getPixels(Tuple!(ubyte, ubyte, ubyte, ubyte)[][] buff) nothrow
    {
        try
        {
            return getPixels((x, y, r, g, b, a) {
                Tuple!(ubyte, ubyte, ubyte, ubyte) color;
                color[0] = r;
                color[1] = g;
                color[2] = b;
                color[3] = a;
                buff[y][x] = color;
                return true;
            });
        }
        catch (Exception ex)
        {
            //TODO toString not nothrow
            return ComResult.error(ex.msg);
        }
    }

    ComResult getPixels(out Tuple!(ubyte, ubyte, ubyte, ubyte)[][] buff) nothrow
    {
        int w, h;
        if (auto err = getWidth(w))
        {
            return err;
        }

        if (auto err = getHeight(h))
        {
            return err;
        }

        auto newBuff = new Tuple!(ubyte, ubyte, ubyte, ubyte)[][](h, w);
        if (auto err = getPixels(newBuff))
        {
            return err;
        }
        buff = newBuff;
        return ComResult.success;
    }

    ComResult setPixels(scope bool delegate(size_t, size_t, out Tuple!(ubyte, ubyte, ubyte, ubyte)) onXYRGBAIsContinue)
    {
        int w, h;
        if (auto err = getWidth(w))
        {
            return err;
        }
        if (auto err = getHeight(h))
        {
            return err;
        }
        foreach (y; 0 .. h)
        {
            foreach (x; 0 .. w)
            {
                Tuple!(ubyte, ubyte, ubyte, ubyte) color;
                bool isContinue = onXYRGBAIsContinue(x, y, color);
                if (auto err = setPixelRGBA(x, y, color[0], color[1], color[2], color[3]))
                {
                    return err;
                }
                if (!isContinue)
                {
                    return ComResult.success;
                }
            }
        }

        return ComResult.success;
    }

    ComResult setPixels(Tuple!(ubyte, ubyte, ubyte, ubyte)[][] buff) nothrow
    {
        try
        {
            return setPixels((x, y, color) { color = buff[y][x]; return true; });
        }
        catch (Exception e)
        {
            //TODO toString not nothrow
            return ComResult.error(e.msg);
        }
    }

    ComResult getPitch(out int value) nothrow
    {
        assert(ptr);
        value = ptr.pitch;
        return ComResult.success;
    }

    ComResult getFormat(out uint value) nothrow
    {
        assert(ptr);
        value = ptr.format;
        return ComResult.success;
    }

    SDL_PixelFormat getPixelFormat() inout nothrow
    {
        assert(ptr);
        return ptr.format;
    }

    ComResult getWidth(out int w) nothrow
    {
        assert(ptr);
        w = ptr.w;
        return ComResult.success;
    }

    ComResult getHeight(out int h) nothrow
    {
        assert(ptr);
        h = ptr.h;
        return ComResult.success;
    }

    ComResult nativePtr(out ComNativePtr nptr) nothrow
    {
        assert(ptr);
        nptr = ComNativePtr(ptr);
        return ComResult.success;
    }

    override protected bool disposePtr() nothrow
    {
        if (ptr)
        {
            SDL_DestroySurface(ptr);
            ptr = null;
            return true;
        }
        return false;
    }
}
