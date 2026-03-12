module api.dm.back.sdl3.sdl_surface;

import api.dm.com.ptrs.com_native_ptr : ComNativePtr;
import api.dm.com.graphics.com_surface : ComSurface;
import api.dm.com.graphics.com_blend_mode : ComBlendMode;
import api.dm.com.com_result : ComResult;
import api.dm.com.ptrs.com_native_ptr : ComNativePtr;
import api.dm.back.sdl3.base.sdl_object_wrapper : SdlObjectWrapper;
import api.dm.back.sdl3.sdl_window : SdlWindow;
import api.dm.com.ptrs.com_native_ptr : ComNativePtr;

import api.math.geom2.rect2 : Rect2f;

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

    ComResult createRaw(void* ptr) nothrow
    {
        return updatePtr(cast(SDL_Surface*) ptr);
    }

    ComResult createRGB24(int width, int height) nothrow
    {
        return create(width, height, SDL_PIXELFORMAT_RGB24);
    }

    ComResult createRGBA32(int width, int height) nothrow
    {
        return create(width, height, SDL_PIXELFORMAT_RGBA32);
    }

    ComResult createBGRA32(int width, int height) nothrow => create(width, height, SDL_PIXELFORMAT_BGRA32);

    ComResult create(int newWidth, int newHeight, uint format) nothrow
    {
        if (hasPtr)
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
        if (!hasPtr)
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

        if (hasPtr)
        {
            disposePtr;
        }

        ptr = SDL_CreateSurfaceFrom(newWidth, newHeight, cast(SDL_PixelFormat) format, pixels, pitch);
        if (!hasPtr)
        {
            return getErrorRes("Cannot create surface from pixels.");
        }
        return ComResult.success;
    }

    ComResult create(ComNativePtr newPtr) nothrow
    {
        SDL_Surface* newSdlPtr = newPtr.castSafe!(SDL_Surface*);
        assert(newSdlPtr);

        if (hasPtr)
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

        SDL_Surface* ptr = SDL_GetWindowSurface(window.ptr);
        if (!ptr)
        {
            return ComResult.error("Surface pointer from window is null");
        }
        if (const err = surfaceForPtr.updatePtr(ptr))
        {
            return err;
        }
        return ComResult.success;
    }

    ComResult convert(SDL_PixelFormat format) nothrow
    {
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
        return scaleTo(dest.ptr, destRect);
    }

    protected ComResult scaleTo(SDL_Surface* destPtr, SDL_Rect* dstRect) nothrow
    {
        return scaleTo(destPtr, null, dstRect);
    }

    protected ComResult scaleTo(SDL_Surface* destPtr, SDL_Rect* srcRect, SDL_Rect* dstRect) nothrow
    {
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
        assert(hasPtr);
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

        if (const err = updatePtr(newSurfacePtr))
        {
            return err;
        }
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

        return target.createRaw(copy);
    }

    ComResult copyTo(ComSurface dst) nothrow
    {
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

    ComResult copyTo(ComSurface dst, Rect2f dstRect) nothrow
    {
        SDL_Rect sdlDstRect = {
            cast(int) dstRect.x, cast(int) dstRect.y, cast(int) dstRect.width, cast(int) dstRect
                .height
        };
        return copyTo(null, dst, &sdlDstRect);
    }

    ComResult copyTo(Rect2f srcRect, ComSurface dst, Rect2f dstRect) nothrow
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
        ComNativePtr dstPtr = dst.nativePtr;
        SDL_Surface* sdlDstPtr = dstPtr.castSafe!(SDL_Surface*);
        assert(sdlDstPtr);

        return copyTo(srcRect, sdlDstPtr, dstRect);
    }

    ComResult copyTo(SDL_Rect* srcRect, SDL_Surface* dst, SDL_Rect* dstRect) nothrow
    {
        if (!SDL_BlitSurface(ptr, srcRect, dst, dstRect))
        {
            return getErrorRes("Error surface copying");
        }
        return ComResult.success;
    }

    ComResult getCopyAlphaMod(out int mod) nothrow
    {
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
        //srcA = srcA * (alpha / 255)
        if (!SDL_SetSurfaceAlphaMod(ptr, cast(ubyte) alpha))
        {
            return getErrorRes("Error setting surface copy alhpa mod value");
        }
        return ComResult.success;
    }

    ComResult setBlendMode(ComBlendMode mode) nothrow
    {
        if (!SDL_SetSurfaceBlendMode(ptr, toNativeBlendMode(mode)))
        {
            return getErrorRes("Error setting surface blend mode");
        }
        return ComResult.success;
    }

    ComResult getBlendMode(out ComBlendMode mode) nothrow
    {
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
        SDL_PixelFormatDetails* details = getFormatDetails(format);
        if (!details)
        {
            return ComResult.error("Format details is null");
        }

        SDL_Palette* palette = getPalette;

        if (!SDL_SetSurfaceColorKey(ptr, colorKey, SDL_MapRGBA(
                details, palette, r, g, b, a)))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    SDL_PixelFormatDetails* getFormatDetails(SDL_PixelFormat format) nothrow
    {
        return SDL_GetPixelFormatDetails(format);
    }

    SDL_Palette* getPalette() nothrow
    {
        return SDL_GetSurfacePalette(ptr);
    }

    ComResult lock() nothrow
    {
        //TODO  SDL_MUSTLOCK(surface)
        if (!SDL_LockSurface(ptr))
        {
            return getErrorRes("Error surface locking");
        }
        return ComResult.success;
    }

    ComResult unlock() nothrow
    {
        SDL_UnlockSurface(ptr);

        return ComResult.success;
    }

    void* pixels() => ptr.pixels;

    ComResult getPixelsRGBA(out void* pixPtr) nothrow
    {
        pixPtr = ptr.pixels;
        if (!pixPtr)
        {
            return ComResult.error("Pixels pointer is null");
        }
        return ComResult.success;
    }

    bool getPixel(int x, int y, out uint* pixel) nothrow
    {
        //TODO cache
        SDL_PixelFormatDetails* details = getFormatDetails(ptr.format);
        if (!details)
        {
            return false;
        }
        //TODO check bounds
        //SDL_ReadSurfacePixel
        pixel = cast(Uint32*)(
            cast(
                Uint8*) ptr.pixels + y * ptr.pitch + x * details.bytes_per_pixel);
        return true;
    }

    bool setPixel(int x, int y, ubyte r, ubyte g, ubyte b, ubyte a) nothrow
    {
        uint* pixelPtr;
        if (!getPixel(x, y, pixelPtr))
        {
            return false;
        }
        return setPixel(pixelPtr, r, g, b, a);
    }

    bool getPixel(uint* pixel, out ubyte r, out ubyte g, out ubyte b, out ubyte a) nothrow
    {
        SDL_PixelFormatDetails* details = getFormatDetails(ptr.format);
        if (!details)
        {
            return false;
        }

        SDL_Palette* palette = getPalette;

        //SDL_WriteSurfacePixel
        SDL_GetRGBA(*pixel, details, palette, &r, &g, &b, &a);
        return true;
    }

    bool setPixel(uint* pixel, ubyte r, ubyte g, ubyte b, ubyte a) nothrow
    {
        SDL_PixelFormatDetails* details = getFormatDetails(ptr.format);
        SDL_Palette* palette = getPalette;

        if (!details)
        {
            return false;
        }

        Uint32 color = SDL_MapRGBA(details, palette, r, g, b, a);
        *pixel = color;
        return true;
    }

    void onPixelsRGBA(scope bool delegate(size_t x, size_t y, uint* pixel) onXYPixelIsContinue) @trusted
    {
        int h = getHeight;
        int w = getWidth;
        ubyte* pixelsPtr = cast(ubyte*) pixels;
        auto pixelsPitch = pitch;

        foreach (y; 0 .. h)
        {
            uint* rowPtr = cast(uint*)(pixelsPtr + y * pixelsPitch);
            foreach (x; 0 .. w)
            {
                uint* pixelPtr = &rowPtr[x];
                if (!onXYPixelIsContinue(x, y, pixelPtr))
                {
                    return;
                }
            }
        }
    }

    bool getPixelsRGBA(scope bool delegate(size_t, size_t, ubyte, ubyte, ubyte, ubyte) onXYRGBAIsContinue) @trusted
    {
        bool result = true;
        onPixelsRGBA((x, y, pixelPtr) {

            ubyte r, g, b, a;
            if (!getPixel(pixelPtr, r, g, b, a))
            {
                result = false;
                return false;
            }

            return onXYRGBAIsContinue(x, y, r, g, b, a);
        });

        return result;
    }

    bool setPixelsRGBA(scope bool delegate(size_t x, size_t y, ref ubyte r, ref ubyte g, ref ubyte b, ref ubyte a) onXYRGBAIsContinue) @trusted
    {
        bool result = true;

        onPixelsRGBA((x, y, pixelPtr) {
            ubyte r, g, b, a;
            bool isContinue = onXYRGBAIsContinue(x, y, r, g, b, a);
            if (!setPixel(pixelPtr, r, g, b, a))
            {
                result = false;
                return false;
            }

            return isContinue;
        });

        return result;
    }

    ComResult fill(ubyte r, ubyte g, ubyte b, ubyte a) nothrow
    {
        const float maxValue = ubyte.max;
        if (!SDL_ClearSurface(ptr, r / maxValue, g / maxValue, b / maxValue, a / maxValue))
        {
            return getErrorRes("Error clearing surface");
        }
        return ComResult.success;
    }

    alias pitch = getPitch;

    int getPitch() nothrow => ptr.pitch;

    uint getFormat() nothrow
    {
        assert(hasPtr);
        return pixelFormat;
    }

    SDL_PixelFormat pixelFormat() nothrow => ptr.format;

    int getWidth() nothrow => ptr.w;
    int getHeight() nothrow => ptr.h;

    void getSize(out int w, out int h)
    {
        w = getWidth;
        h = getHeight;
    }

    ComResult saveBMP(const(char)[] file) nothrow
    {
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

        if (const err = updatePtr(newPtr))
        {
            return err;
        }

        return ComResult.success;
    }

    string lastError() => getError;

    protected override bool disposePtr() nothrow
    {
        if (hasPtr)
        {
            SDL_DestroySurface(ptr);
            return true;
        }
        return false;
    }
}
