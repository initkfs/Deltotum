module dm.back.sdl2.sdl_surface;

// dfmt off
version(SdlBackend):
// dfmt on

import dm.com.graphics.com_surface : ComSurface;
import dm.com.graphics.com_blend_mode : ComBlendMode;
import dm.com.platforms.results.com_result : ComResult;
import dm.back.sdl2.base.sdl_object_wrapper : SdlObjectWrapper;
import dm.back.sdl2.sdl_window : SdlWindow;

import dm.math.rect2d : Rect2d;
import std.typecons : Tuple;

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

    ComResult createRGB(int width, int height) nothrow
    {
        if (ptr)
        {
            disposePtr;
        }
        //TODO or SDL_BYTEORDER?
        version (BigEndian)
        {
            if (const createErr = createRGB(
                    0,
                    width,
                    height,
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
            if (const createErr = createRGB(0, width, height, 32,
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

    ComResult createRGB(uint flags = 0, int width = 10, int height = 10, int depth = 32,
        uint rmask = 0, uint gmask = 0, uint bmask = 0, uint amask = 0) nothrow
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

    ComResult createRGB(void* pixels, int width, int height, int depth, int pitch,
        uint rmask, uint gmask, uint bmask, uint amask) nothrow
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
        uint rmask, uint gmask, uint bmask, uint amask) nothrow
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

    ComResult createFromPtr(void* newPtr) nothrow
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

    ComResult convertSurfacePtr(SDL_Surface* src, out SDL_Surface* dest, SDL_PixelFormat* format, uint flags = 0) const nothrow
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

    protected ComResult scaleToPtr(SDL_Surface* destPtr, SDL_Rect* bounds) nothrow
    {
        const int zeroOrErrorCode = SDL_BlitScaled(ptr, null, destPtr, bounds);
        return ComResult(zeroOrErrorCode);
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
            return ComResult.success;
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

    ComResult blitPtr(SDL_Rect* srcRect, SDL_Surface* dst, SDL_Rect* dstRect) nothrow
    {
        const int zeroOrErrorCode = SDL_BlitSurface(ptr, srcRect, dst, dstRect);
        return ComResult(zeroOrErrorCode);
    }

    ComResult getBlitAlphaMod(out int mod) nothrow
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

    ComResult setBlitAlhpaMod(int alpha) nothrow
    {
        //srcA = srcA * (alpha / 255)
        const int zeroOrErrorCode = SDL_SetSurfaceAlphaMod(ptr, cast(ubyte) alpha);
        return ComResult(zeroOrErrorCode);
    }

    ComResult setBlendMode(ComBlendMode mode) nothrow
    {
        const int zeroOrErrorCode = SDL_SetSurfaceBlendMode(ptr, typeConverter.toNativeBlendMode(
                mode));
        return ComResult(zeroOrErrorCode);
    }

    ComResult getBlendMode(out ComBlendMode mode) nothrow
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

    ComResult setPixelIsTransparent(bool isTransparent, ubyte r, ubyte g, ubyte b, ubyte a) nothrow
    {
        const colorKey = isTransparent ? SDL_TRUE : SDL_FALSE;
        const int zeroOrErrorCode = SDL_SetColorKey(ptr, colorKey, SDL_MapRGBA(
                ptr.format, r, g, b, a));
        return ComResult(zeroOrErrorCode);
    }

    ComResult lock() nothrow
    {
        assert(ptr);
        const int zeroOrErrorCode = SDL_LockSurface(ptr);
        return ComResult(zeroOrErrorCode);
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
        //TODO check bounds
        pixel = cast(Uint32*)(
            cast(
                Uint8*) ptr.pixels + y * ptr.pitch + x * ptr.format.BytesPerPixel);
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
        SDL_GetRGBA(*pixel, ptr.format, &r, &g, &b, &a);
        return ComResult.success;
    }

    ComResult setPixelRGBA(uint* pixel, ubyte r, ubyte g, ubyte b, ubyte a) nothrow
    {
        Uint32 color = SDL_MapRGBA(ptr.format, r, g, b, a);
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
            return ComResult.error(ex.message);
        }
    }

    ComResult getPixels(out Tuple!(ubyte, ubyte, ubyte, ubyte)[][] buff) nothrow
    {
        int w, h;
        if(auto err = getWidth(w)){
            return err;
        }

        if(auto err = getHeight(h)){
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
        if(auto err = getWidth(w)){
            return err;
        }
        if(auto err = getHeight(h)){
            return err;
        }
        foreach (y; 0 .. h)
        {
            foreach (x; 0 .. w)
            {
                Tuple!(ubyte, ubyte, ubyte, ubyte) color;
                bool isContinue = onXYRGBAIsContinue(x, y, color);
                if(auto err = setPixelRGBA(x, y, color[0], color[1], color[2], color[3])){
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
            return ComResult.error(e.message);
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
        value = ptr.format.format;
        return ComResult.success;
    }

    inout(SDL_PixelFormat*) getPixelFormat() inout nothrow
    in (ptr !is null)
    {
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

    ComResult nativePtr(out void* nptr) nothrow
    {
        assert(this.ptr);
        nptr = cast(void*) ptr;
        return ComResult.success;
    }

    override protected bool disposePtr() nothrow
    {
        if (ptr)
        {
            SDL_FreeSurface(ptr);
            return true;
        }
        return false;
    }
}
