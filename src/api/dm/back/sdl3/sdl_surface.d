module api.dm.back.sdl3.sdl_surface;

import api.dm.com.com_native_ptr : ComNativePtr;
import api.dm.com.graphics.com_surface : ComSurface;
import api.dm.com.graphics.com_blend_mode : ComBlendMode;
import api.dm.com.com_result : ComResult;
import api.dm.com.com_native_ptr : ComNativePtr;
import api.dm.back.sdl3.base.sdl_object_wrapper : SdlObjectWrapper;
import api.dm.back.sdl3.sdl_window : SdlWindow;
import api.dm.com.com_native_ptr : ComNativePtr;

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

    ComResult createUnsafe(void* ptr) nothrow
    {
        return setWithDispose(cast(SDL_Surface*) ptr);
    }

    ComResult createRGBA32(int width, int height) nothrow
    {
        return create(width, height, SDL_PIXELFORMAT_RGBA32);
    }

    ComResult createABGR32(int width, int height) nothrow
    {
        return create(width, height, SDL_PIXELFORMAT_ABGR32);
    }

    ComResult createARGB32(int width, int height) nothrow => create(width, height, SDL_PIXELFORMAT_ARGB32);
    ComResult createBGRA32(int width, int height) nothrow => create(width, height, SDL_PIXELFORMAT_BGRA32);

    ComResult create(int newWidth, int newHeight, uint format) nothrow
    {
        if (ptr)
        {
            disposePtr;
        }

        if (newWidth <= 0)
        {
            return ComResult.error("Cannot create surface: width must be positive number");
        }

        if (newHeight <= 0)
        {
            return ComResult.error("Cannot create surface: height must be positive number");
        }

        ptr = createPtr(newWidth, newHeight, format);
        if (!ptr)
        {
            return getErrorRes("Cannot create surface: surface pointer is null");
        }

        return ComResult.success;
    }

    ComResult create(void* pixels, int newWidth, int newHeight, uint format, int pitch) nothrow
    {
        assert(pixels);
        assert(pitch >= 0);

        if (newWidth <= 0)
        {
            return ComResult.error(
                "Cannot create surface from pixels. Width must be positive number");
        }

        if (newHeight <= 0)
        {
            return ComResult.error(
                "Cannot create surface from pixels. Height must be positive number");
        }

        if (ptr)
        {
            disposePtr;
        }

        ptr = SDL_CreateSurfaceFrom(newWidth, newHeight, cast(SDL_PixelFormat) format, pixels, pitch);
        if (!ptr)
        {
            return getErrorRes("Cannot create surface from pixels.");
        }
        return ComResult.success;
    }

    ComResult create(ComNativePtr newPtr) nothrow
    {
        SDL_Surface* newSdlPtr = newPtr.castSafe!(SDL_Surface*);
        assert(newSdlPtr);

        if (ptr)
        {
            disposePtr;
        }

        this.ptr = newSdlPtr;
        return ComResult.success;
    }

    SDL_Surface* createPtr(int width, int height, uint format) nothrow
    {
        auto newPtr = SDL_CreateSurface(width, height, cast(SDL_PixelFormat) format);
        return newPtr;
    }

    static ComResult getWindowSurface(SdlWindow window, SdlSurface surfaceForPtr) nothrow
    {
        assert(window);
        assert(surfaceForPtr);

        SDL_Surface* ptr = SDL_GetWindowSurface(window.getObject);
        if (!ptr)
        {
            return ComResult.error("Surface pointer from window is null");
        }
        surfaceForPtr.updateObject(ptr);
        return ComResult.success;
    }

    ComResult convert(SDL_PixelFormat format) nothrow
    {
        assert(ptr);

        // Returns the new SDL_Surface
        SDL_Surface* newPtr = SDL_ConvertSurface(ptr, format);
        if (!newPtr)
        {
            return getErrorRes("New surface сonverted pointer is null.");
        }
        SDL_DestroySurface(ptr);
        ptr = newPtr;
        return ComResult.success;
    }

    ComResult convert(SDL_Surface* src, out SDL_Surface* dest, SDL_PixelFormat format) nothrow
    {
        assert(src);

        // Returns the new SDL_Surface
        SDL_Surface* ptr = SDL_ConvertSurface(src, format);
        if (!ptr)
        {
            return getErrorRes("New surface сonverted pointer is null.");
        }
        dest = ptr;
        //SDL_DestroySurface(src)
        return ComResult.success;
    }

    ComResult scaleTo(SdlSurface dest, SDL_Rect* destRect) nothrow
    {
        return scaleTo(dest.getObject, destRect);
    }

    protected ComResult scaleTo(SDL_Surface* destPtr, SDL_Rect* dstRect) nothrow
    {
        return scaleTo(destPtr, null, dstRect);
    }

    protected ComResult scaleTo(SDL_Surface* destPtr, SDL_Rect* srcRect, SDL_Rect* dstRect) nothrow
    {
        assert(ptr);
        assert(destPtr);

        SDL_ScaleMode scaleMode = SDL_SCALEMODE_LINEAR;
        if (!SDL_BlitSurfaceScaled(ptr, srcRect, destPtr, dstRect, scaleMode))
        {
            return getErrorRes("Error surface copy with scaling");
        }
        return ComResult.success;
    }

    ComResult resize(int newWidth, int newHeight, out bool isResized) nothrow
    {
        assert(ptr);
        //https://stackoverflow.com/questions/40850196/sdl2-resize-a-surface
        // https://stackoverflow.com/questions/33850453/sdl2-copy-scaled-from-a-palettized-8bpp-surface-gives-error-copy-combination/33944312
        if (newWidth <= 0 || newHeight <= 0)
        {
            return ComResult.error("Surface size must be positive values");
        }

        int w = getWidth;
        int h = getHeight;

        if (w == newWidth && h == newHeight)
        {
            return ComResult.success;
        }

        SDL_Rect dest;
        dest.x = 0;
        dest.y = 0;
        dest.w = newWidth;
        dest.h = newHeight;

        auto newSurfacePtr = createPtr(dest.w, dest.h, pixelFormat);
        if (!newSurfacePtr)
        {
            return getErrorRes("Resizing error: new surface pointer is null");
        }

        if (const err = scaleTo(newSurfacePtr, &dest))
        {
            return err;
        }

        updateObject(newSurfacePtr);
        isResized = true;
        return ComResult.success;
    }

    ComResult rotateTo(float angleDeg, ComSurface target)
    {
        SDL_Surface* copy = SDL_RotateSurface(ptr, angleDeg);
        if (!copy)
        {
            return getErrorRes("Cannot rotate surface");
        }

        return target.createUnsafe(copy);
    }

    ComResult copyTo(ComSurface dst) nothrow
    {
        assert(ptr);
        assert(dst);

        auto newSurfacePtr = SDL_DuplicateSurface(ptr);
        if (!newSurfacePtr)
        {
            return getErrorRes("Cannot duplicate surface");
        }

        if (const err = dst.create(ComNativePtr(newSurfacePtr)))
        {
            return err;
        }
        return ComResult.success;
    }

    ComResult copyTo(ComSurface dst, Rect2d dstRect) nothrow
    {
        SDL_Rect sdlDstRect = {
            cast(int) dstRect.x, cast(int) dstRect.y, cast(int) dstRect.width, cast(int) dstRect
                .height
        };
        return copyTo(null, dst, &sdlDstRect);
    }

    ComResult copyTo(Rect2d srcRect, ComSurface dst, Rect2d dstRect) nothrow
    {
        SDL_Rect sdlSrcRect = {
            cast(int) srcRect.x, cast(int) srcRect.y, cast(int) srcRect.width, cast(int) srcRect
                .height
        };

        SDL_Rect sdlDstRect = {
            cast(int) dstRect.x, cast(int) dstRect.y, cast(int) dstRect.width, cast(int) dstRect
                .height
        };
        return copyTo(&sdlSrcRect, dst, &sdlDstRect);
    }

    //https://discourse.libsdl.org/t/sdl-blitsurface-doesnt-work-in-sdl-2-0/19288/3
    ComResult copyTo(SDL_Rect* srcRect, ComSurface dst, SDL_Rect* dstRect) nothrow
    {
        ComNativePtr dstPtr;

        //TODO unsafe
        if (const err = dst.nativePtr(dstPtr))
        {
            return err;
        }

        SDL_Surface* sdlDstPtr = dstPtr.castSafe!(SDL_Surface*);
        assert(sdlDstPtr);

        return copyTo(srcRect, sdlDstPtr, dstRect);
    }

    ComResult copyTo(SDL_Rect* srcRect, SDL_Surface* dst, SDL_Rect* dstRect) nothrow
    {
        assert(ptr);
        if (!SDL_BlitSurface(ptr, srcRect, dst, dstRect))
        {
            return getErrorRes("Error surface copying");
        }
        return ComResult.success;
    }

    ComResult getCopyAlphaMod(out int mod) nothrow
    {
        assert(ptr);

        ubyte oldMod;
        if (!SDL_GetSurfaceAlphaMod(ptr, &oldMod))
        {
            return getErrorRes("Error getting surface copy alhpa mod value");
        }

        mod = oldMod;
        return ComResult.success;
    }

    ComResult setCopyAlphaMod(int alpha) nothrow
    {
        assert(ptr);

        //srcA = srcA * (alpha / 255)
        if (!SDL_SetSurfaceAlphaMod(ptr, cast(ubyte) alpha))
        {
            return getErrorRes("Error setting surface copy alhpa mod value");
        }
        return ComResult.success;
    }

    ComResult setBlendMode(ComBlendMode mode) nothrow
    {
        assert(ptr);

        if (!SDL_SetSurfaceBlendMode(ptr, toNativeBlendMode(mode)))
        {
            return getErrorRes("Error setting surface blend mode");
        }
        return ComResult.success;
    }

    ComResult getBlendMode(out ComBlendMode mode) nothrow
    {
        assert(ptr);

        SDL_BlendMode sdlMode;
        if (!SDL_GetSurfaceBlendMode(ptr, &sdlMode))
        {
            return getErrorRes("Error getting surface blend mode");
        }

        mode = fromNativeBlendMode(sdlMode);
        return ComResult.success;
    }

    ComResult setPixelIsTransparent(bool isTransparent, ubyte r, ubyte g, ubyte b, ubyte a) nothrow
    {
        sdlbool colorKey = isTransparent;

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

    ComResult getFormatDetails(SDL_PixelFormat format, out SDL_PixelFormatDetails* details) nothrow
    {
        SDL_PixelFormatDetails* detailsPtr = SDL_GetPixelFormatDetails(format);
        if (!detailsPtr)
        {
            return getErrorRes("Error getting format details");
        }
        details = detailsPtr;
        return ComResult.success;
    }

    ComResult getPalette(out SDL_Palette* palette) nothrow
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
            return getErrorRes("Error surface locking");
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
        if (!pixPtr)
        {
            return ComResult.error("Pixels pointer is null");
        }
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
        //SDL_ReadSurfacePixel
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

        //SDL_WriteSurfacePixel
        SDL_GetRGBA(*pixel, details, palette, &r, &g, &b, &a);
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

    ComResult getPixels(scope bool delegate(size_t, size_t, ubyte, ubyte, ubyte, ubyte) onXYRGBAIsContinue) @trusted
    {
        int h = getHeight;
        int w = getWidth;

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
        int w = getWidth;
        int h = getHeight;

        auto newBuff = new Tuple!(ubyte, ubyte, ubyte, ubyte)[][](h, w);
        if (auto err = getPixels(newBuff))
        {
            return err;
        }
        buff = newBuff;
        return ComResult.success;
    }

    ComResult setPixels(scope bool delegate(size_t, size_t, out Tuple!(ubyte, ubyte, ubyte, ubyte)) onXYRGBAIsContinue) @trusted
    {
        int w = getWidth;
        int h = getHeight;

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

    ComResult fill(ubyte r, ubyte g, ubyte b, ubyte a) nothrow
    {
        assert(ptr);
        const float maxValue = ubyte.max;
        if (!SDL_ClearSurface(ptr, r / maxValue, g / maxValue, b / maxValue, a / maxValue))
        {
            return getErrorRes("Error clearing surface");
        }
        return ComResult.success;
    }

    int getPixelRowLenBytes() nothrow
    {
        assert(ptr);
        return ptr.pitch;
    }

    uint getFormat() nothrow
    {
        assert(ptr);
        return pixelFormat;
    }

    SDL_PixelFormat pixelFormat() nothrow
    {
        assert(ptr);
        return ptr.format;
    }

    int getWidth() nothrow
    {
        assert(ptr);
        return ptr.w;
    }

    int getHeight() nothrow
    {
        assert(ptr);
        return ptr.h;
    }

    void getSize(out int w, out int h)
    {
        w = getWidth;
        h = getHeight;
    }

    ComResult nativePtr(out ComNativePtr nptr) nothrow
    {
        assert(ptr);
        nptr = ComNativePtr(ptr);
        return ComResult.success;
    }

    ComResult saveBMP(const(char)[] file) nothrow
    {
        assert(ptr);
        if (!SDL_SaveBMP(ptr, file.ptr))
        {
            return getErrorRes("Error saving surface to bmp file");
        }
        return ComResult.success;
    }

    ComResult loadBMP(const(char)[] file) nothrow
    {
        auto newPtr = SDL_LoadBMP(file.ptr);
        if (!newPtr)
        {
            return getErrorRes("Error loading surface from file");
        }

        updateObject(newPtr);

        return ComResult.success;
    }

    string getLastErrorNew() => getError;

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
