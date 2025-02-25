module api.dm.back.sdl3.sdl_texture;

// dfmt off
version(SdlBackend):
// dfmt on

import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.com.graphics.com_texture : ComTexture;
import api.dm.com.com_native_ptr : ComNativePtr;
import api.dm.back.sdl3.base.sdl_object_wrapper : SdlObjectWrapper;
import api.dm.back.sdl3.sdl_renderer : SdlRenderer;
import api.dm.com.graphics.com_surface : ComSurface;
import api.dm.com.graphics.com_blend_mode : ComBlendMode;
import api.dm.com.graphics.com_texture : ComTextureScaleMode;

import api.math.geom2.rect2 : Rect2d;
import api.math.flip : Flip;

import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */
class SdlTexture : SdlObjectWrapper!SDL_Texture, ComTexture
{
    //TODO move to RgbaTexture
    private
    {
        double _opacity = 0;
        SdlRenderer renderer;

        bool locked;
        //pitch == length row of pixels in bytes
        int pitch;
        uint* pixelPtr;

        SDL_Texture* lastRendererTarget;
    }

    protected
    {
        //TODO getDepth?
        int depth = 32;
    }

    this(SdlRenderer renderer, string id = "sdl_texture") pure
    {
        assert(renderer);
        this.renderer = renderer;
        setNotEmptyId(id);
    }

    protected this(SDL_Texture* ptr, SdlRenderer renderer, string id = "sdl_texture")
    {
        super(ptr);
        this.renderer = renderer;
        setNotEmptyId(id);
    }

    ComResult createFromSurface(ComSurface surface) nothrow
    {
        assert(surface, "Surface must not be null");
        if (ptr)
        {
            disposePtr;
        }
        ComNativePtr newPtr;
        if (const err = surface.nativePtr(newPtr))
        {
            return err;
        }
        SDL_Surface* surfPtr = newPtr.castSafe!(SDL_Surface*);
        return fromSurfacePtr(surfPtr);
    }

    ComResult fromSurfacePtr(SDL_Surface* surface) nothrow
    {
        assert(surface, "Surface ptr must not be null");
        if (ptr)
        {
            disposePtr;
        }

        ptr = SDL_CreateTextureFromSurface(renderer.getObject, surface);
        if (!ptr)
        {
            return getErrorRes("Unable create texture from renderer and surface.");
        }
        //TODO side effect 
        if (!SDL_SetTextureBlendMode(ptr, SDL_BLENDMODE_BLEND))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult recreatePtr(void* newPtr) nothrow
    {
        assert(newPtr);

        if (ptr)
        {
            disposePtr;
        }
        ptr = cast(SDL_Texture*) newPtr;
        return ComResult.success;
    }

    protected ComResult query(int* width, int* height, uint* format, uint* access) nothrow
    {
        if (!ptr)
        {
            return ComResult.error("Texture2d query error: texture ponter is null");
        }

        SDL_PropertiesID propId = SDL_GetTextureProperties(ptr);
        if (propId == 0)
        {
            return getErrorRes;
        }

        if (format)
        {
            *format = cast(uint) SDL_GetNumberProperty(propId, SDL_PROP_TEXTURE_FORMAT_NUMBER.ptr, 0);
        }
        if (access)
        {
            *access = cast(uint) SDL_GetNumberProperty(propId, SDL_PROP_TEXTURE_ACCESS_NUMBER.ptr, 0);
        }
        if (width)
        {
            *width = cast(int) SDL_GetNumberProperty(propId, SDL_PROP_TEXTURE_WIDTH_NUMBER.ptr, 0);
        }

        if (height)
        {
            *height = cast(int) SDL_GetNumberProperty(propId, SDL_PROP_TEXTURE_HEIGHT_NUMBER.ptr, 0);
        }

        return ComResult.success;
    }

    ComResult getFormat(out uint format) nothrow
    {
        if (const err = query(null, null, &format, null))
        {
            return err;
        }
        return ComResult.success;
    }

    protected ComResult getDetails(SDL_PixelFormat format, out SDL_PixelFormatDetails* details) nothrow
    {
        SDL_PixelFormatDetails* detailsPtr = SDL_GetPixelFormatDetails(format);
        if (!detailsPtr)
        {
            return getErrorRes;
        }
        details = detailsPtr;
        return ComResult.success;
    }

    ComResult getSize(out int width, out int height) nothrow
    {
        return query(&width, &height, null, null);
    }

    ComResult getRendererTarget(ref SDL_Texture* target) nothrow
    {
        auto t = SDL_GetRenderTarget(renderer.getObject);
        target = t;
        return ComResult.success;
    }

    ComResult setRendererTarget() nothrow
    {
        assert(!lastRendererTarget, "Last renderer target must be null");
        if (const err = getRendererTarget(lastRendererTarget))
        {
            return err;
        }

        if (!SDL_SetRenderTarget(renderer.getObject, ptr))
        {
            return getErrorRes("Fail set rendered target");
        }
        return ComResult.success;
    }

    ComResult restoreRendererTarget() nothrow
    {
        SDL_Texture* target = null;
        if (lastRendererTarget)
        {
            target = lastRendererTarget;
            lastRendererTarget = null;
        }

        if (!SDL_SetRenderTarget(renderer.getObject, target))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    protected ComResult create(SDL_PixelFormat format,
        SDL_TextureAccess access, int w,
        int h) nothrow
    {
        if (ptr)
        {
            disposePtr;
        }

        ptr = SDL_CreateTexture(renderer.getObject, format, access, w, h);
        if (!ptr)
        {
            return getErrorRes("Unable create texture.");
        }

        return ComResult.success;
    }

    protected ComResult getAlphaMod(out ubyte alpha) nothrow
    {
        if (!SDL_GetTextureAlphaMod(ptr, &alpha))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    protected ComResult setAlphaMod(ubyte alpha) nothrow
    {
        if (!SDL_SetTextureAlphaMod(ptr, alpha))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult getColor(out ubyte r, out ubyte g, out ubyte b, out ubyte a) nothrow
    {
        if (!SDL_GetTextureColorMod(ptr, &r, &g, &b))
        {
            return getErrorRes;
        }
        return getAlphaMod(a);
    }

    ComResult setColor(ubyte r, ubyte g, ubyte b, ubyte a) nothrow
    {
        if (!SDL_SetTextureColorMod(ptr, r, g, b))
        {
            return getErrorRes;
        }
        return setAlphaMod(a);
    }

    ComResult createMutARGB8888(int width, int height)
    {
        return create(SDL_PIXELFORMAT_ARGB8888,
            SDL_TextureAccess.SDL_TEXTUREACCESS_STREAMING, width,
            height);
    }

    ComResult createMutRGBA32(int width, int height)
    {
        //alias SDL_PIXELFORMAT_RGBA32 = SDL_PIXELFORMAT_ABGR8888;
        return create(SDL_PIXELFORMAT_RGBA32,
            SDL_TextureAccess.SDL_TEXTUREACCESS_STREAMING, width,
            height);
    }

    ComResult createMutARGB32(int width, int height)
    {
        return create(SDL_PIXELFORMAT_ARGB8888,
            SDL_TextureAccess.SDL_TEXTUREACCESS_STREAMING, width,
            height);
    }

    ComResult createImmutRGBA32(int width, int height)
    {
        return create(SDL_PIXELFORMAT_RGBA32,
            SDL_TextureAccess.SDL_TEXTUREACCESS_STATIC, width,
            height);
    }

    ComResult createTargetRGBA32(int width, int height)
    {
        return create(SDL_PIXELFORMAT_RGBA32,
            SDL_TextureAccess.SDL_TEXTUREACCESS_TARGET, width,
            height);
    }

    ComResult lock() nothrow
    {
        assert(ptr);
        assert(!locked);
        if (!SDL_LockTexture(ptr, null, cast(void**)&pixelPtr, &pitch))
        {
            return getErrorRes;
        }

        locked = true;
        return ComResult.success;
    }

    ComResult unlock() nothrow
    {
        assert(locked);
        assert(ptr);
        SDL_UnlockTexture(ptr);
        //TODO check unlock?
        locked = false;
        pixelPtr = null;
        pitch = 0;
        return ComResult.success;
    }

    ComResult getPixelRowLenBytes(out int pitch) nothrow
    {
        if (!locked)
        {
            return ComResult.error("Texture2d not locked for pitch");
        }
        pitch = this.pitch;
        return ComResult.success;
    }

    ComResult getPixels(out void* pixels)
    {
        if (!locked)
        {
            return ComResult.error("Texture2d not locked for pixels");
        }
        pixels = cast(void*) pixelPtr;
        return ComResult.success;
    }

    ComResult update(Rect2d rect, void* pixels, int pitch) nothrow
    {
        if (!locked)
        {
            return ComResult.error("Texture2d not locked for update");
        }
        SDL_Rect bounds = {0, 0, cast(int) rect.width, cast(int) rect.height};
        const isUpdate = SDL_UpdateTexture(ptr,
            &bounds, cast(void*) pixelPtr, pitch);
        if (!isUpdate)
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult getPixel(uint x, uint y, out uint* pixel) nothrow
    {
        assert(locked);
        assert(pitch > 0);
        assert(pixelPtr);

        const pixelPosition = (y * (pitch / pitch.sizeof) + x);
        pixel = &pixelPtr[pixelPosition];
        return ComResult.success;
    }

    ComResult setPixelColor(uint x, uint y, ubyte r, ubyte g, ubyte b, ubyte a) nothrow
    {
        assert(locked);
        assert(pixelPtr);
        assert(pitch > 0);
        //TODO pass format as a parameter?
        uint formatValue;
        if (const err = query(null, null, &formatValue, null))
        {
            return err;
        }

        SDL_PixelFormatDetails* details;
        if (const err = getDetails(cast(SDL_PixelFormat) formatValue, details))
        {
            return err;
        }

        Uint32 color = SDL_MapRGBA(details, null, r, g, b, a);
        const pixelPosition = (y * (pitch / pitch.sizeof) + x);

        pixelPtr[pixelPosition] = color;

        return ComResult.success;
    }

    ComResult setPixelColor(uint* ptr, ubyte r, ubyte g, ubyte b, ubyte aByte) nothrow
    {
        uint format;
        if (const formatErr = getFormat(format))
        {
            return formatErr;
        }

        SDL_PixelFormatDetails* details;
        if (const err = getDetails(cast(SDL_PixelFormat) format, details))
        {
            return err;
        }

        Uint32 color = SDL_MapRGBA(details, null, r, g, b, aByte);
        *ptr = color;
        return ComResult.success;
    }

    ComResult getPixelColor(int x, int y, out ubyte r, out ubyte g, out ubyte b, out ubyte aByte) nothrow
    {
        uint* pixel;
        if (const err = getPixel(x, y, pixel))
        {
            return err;
        }
        return getPixelColor(pixel, r, g, b, aByte);
    }

    ComResult getPixelColor(uint* ptr, out ubyte r, out ubyte g, out ubyte b, out ubyte aByte) nothrow
    {
        uint format;
        if (const formatErr = getFormat(format))
        {
            return formatErr;
        }

        SDL_PixelFormatDetails* details;
        if (const err = getDetails(cast(SDL_PixelFormat)format, details))
        {
            return err;
        }

        SDL_GetRGBA(*ptr, details,null,  &r, &g, &b, &aByte);
        return ComResult.success;
    }

    ComResult setBlendMode(ComBlendMode mode) nothrow
    {
        SDL_BlendMode newMode = typeConverter.toNativeBlendMode(mode);
        if (!SDL_SetTextureBlendMode(ptr, newMode))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult setBlendModeBlend() nothrow
    {
        return setBlendMode(ComBlendMode.blend);
    }

    ComResult setBlendModeNone() nothrow
    {
        return setBlendMode(ComBlendMode.none);
    }

    ComResult resize(double newWidth, double newHeight) nothrow
    {
        //TODO remove duplication
        SDL_Rect srcRect, dstRect;

        dstRect.x = 0;
        dstRect.y = 0;
        dstRect.w = cast(int) newWidth;
        dstRect.h = cast(int) newHeight;

        int textureWidth, textureHeight;
        uint format;
        if (const err = query(&textureWidth, &textureHeight, &format, null))
        {
            return err;
        }

        srcRect.x = 0;
        srcRect.y = 0;
        srcRect.w = textureWidth;
        srcRect.h = textureHeight;

        auto tempSrc = SDL_RenderReadPixels(renderer.getObject, &srcRect);
        scope (exit)
        {
            SDL_DestroySurface(tempSrc);
        }

        auto tempDst = SDL_CreateSurface(dstRect.w, dstRect.h, tempSrc.format);
        if (!tempDst)
        {
            return getErrorRes("Temp surface is null for format");
        }

        scope (exit)
        {
            SDL_DestroySurface(tempDst);
        }

        if (const err = setRendererTarget)
        {
            return err;
        }
       
        if (const err = restoreRendererTarget)
        {
            return err;
        }

        SDL_ScaleMode scaleMode = SDL_SCALEMODE_LINEAR;
        const isScaled = SDL_BlitSurfaceScaled(tempSrc, &srcRect, tempDst, &dstRect, scaleMode);
        if (!isScaled)
        {
            return getErrorRes;
        }

        if (const err = fromSurfacePtr(tempDst))
        {
            return err;
        }

        return ComResult.success;
    }

    ComResult draw(Rect2d srcBounds, Rect2d destBounds, double angle = 0, Flip flip = Flip
            .none)
    {
        return draw(this, srcBounds, destBounds, angle, flip);
    }

    ComResult draw(ComTexture other, Rect2d srcBounds, Rect2d destBounds, double angle = 0, Flip flip = Flip
            .none)
    {
        SDL_FRect srcRect;
        srcRect.x = cast(float) srcBounds.x;
        srcRect.y = cast(float) srcBounds.y;
        srcRect.w = cast(float) srcBounds.width;
        srcRect.h = cast(float) srcBounds.height;

        //SDL_Rect bounds = window.getScaleBounds;

        SDL_FRect destRect;
        destRect.x = cast(float)(destBounds.x); // + boundsRect.x);
        destRect.y = cast(float)(destBounds.y); // + boundsRect.y);
        destRect.w = cast(float) destBounds.width;
        destRect.h = cast(float) destBounds.height;

        //FIXME some texture sizes can crash when changing the angle
        //double newW = height * abs(math.sinDeg(angle)) + width * abs(math.cosDeg(angle));
        //double newH = height * abs(math.cosDeg(angle)) + width * abs(math.sinDeg(angle));

        //TODO move to helper
        SDL_FlipMode sdlFlip;
        final switch (flip)
        {
            case Flip.none:
                sdlFlip = SDL_FlipMode.SDL_FLIP_NONE;
                break;
            case Flip.horizontal:
                sdlFlip = SDL_FlipMode.SDL_FLIP_HORIZONTAL;
                break;
            case Flip.vertical:
                sdlFlip = SDL_FlipMode.SDL_FLIP_VERTICAL;
                break;
                sdlFlip = SDL_FlipMode.SDL_FLIP_VERTICAL | SDL_FlipMode.SDL_FLIP_HORIZONTAL;
            case Flip.both:
                break;
        }

        //https://discourse.libsdl.org/t/1st-frame-sdl-renderer-software-sdl-flip-horizontal-ubuntu-wrong-display-is-it-a-bug-of-sdl-rendercopyex/25924
        SdlTexture t = cast(SdlTexture) other;
        assert(t);
        SDL_FPoint* rotateCenter = null;
        return renderer.copyEx(t, &srcRect, &destRect, angle, rotateCenter, sdlFlip);
    }

    ComResult copy(out ComTexture toTexture)
    {
        ComTexture newTexture;
        try
        {
            newTexture = new SdlTexture(renderer);
        }
        catch (Exception e)
        {
            return ComResult.error(e.msg);
        }

        int width, height;
        if (const err = getSize(width, height))
        {
            return err;
        }

        if (const err = newTexture.createTargetRGBA32(width, height))
        {
            return err;
        }

        Rect2d srcRect = {0, 0, width, height};
        Rect2d destRect = {0, 0, width, height};

        if (const err = copyTo(newTexture, srcRect, destRect))
        {
            return err;
        }
        toTexture = newTexture;
        return ComResult.success;
    }

    ComResult copyTo(ComTexture toTexture, Rect2d srcRect, Rect2d destRect, double angle = 0, Flip flip = Flip
            .none)
    {
        if (const err = toTexture.setBlendModeBlend)
        {
            return err;
        }

        if (const err = toTexture.setRendererTarget)
        {
            return err;
        }

        if (const err = draw(srcRect, destRect, angle, flip))
        {
            return err;
        }

        if (const err = restoreRendererTarget)
        {
            return err;
        }

        return ComResult.success;
    }

    ComResult copyFrom(ComTexture other, Rect2d srcRect, Rect2d dstRect, double angle = 0, Flip flip = Flip
            .none)
    {
        if (const err = setBlendModeBlend)
        {
            return err;
        }

        if (const err = setRendererTarget)
        {
            return err;
        }

        if (const err = draw(other, srcRect, dstRect, angle, flip))
        {
            return err;
        }

        if (const err = restoreRendererTarget)
        {
            return err;
        }

        return ComResult.success;
    }

    //TODO type converter
    private ComTextureScaleMode fromSdlMode(SDL_ScaleMode m) nothrow
    {
        final switch (m)
        {
            case SDL_SCALEMODE_NEAREST:
                return ComTextureScaleMode.speed;
            // case SDL_SCALEMODE_LINEAR:
            //     return ComTextureScaleMode.balance;
            case SDL_SCALEMODE_LINEAR:
                return ComTextureScaleMode.quality;
        }
    }

    //TODO type converter
    private SDL_ScaleMode toSdlMode(ComTextureScaleMode m) nothrow
    {
        final switch (m) with (ComTextureScaleMode)
        {
            case speed:
                return SDL_SCALEMODE_NEAREST;
            case quality:
                return SDL_SCALEMODE_LINEAR;
        }
    }

    ComResult setScaleMode(ComTextureScaleMode mode) nothrow
    {
        const nativeMode = toSdlMode(mode);
        if (!SDL_SetTextureScaleMode(ptr, nativeMode))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult getScaleMode(out ComTextureScaleMode mode) nothrow
    {
        SDL_ScaleMode oldMode;
        if (!SDL_GetTextureScaleMode(ptr, &oldMode))
        {
            return getErrorRes;
        }
        mode = fromSdlMode(oldMode);
        return ComResult.success;
    }

    ComResult nativePtr(out ComNativePtr nptr) nothrow
    {
        assert(this.ptr);
        nptr = ComNativePtr(ptr);
        return ComResult.success;
    }

    ComResult isCreated(out bool created) nothrow
    {
        created = ptr !is null;
        return ComResult.success;
    }

    ComResult isLocked(out bool value) nothrow
    {
        value = locked;
        return ComResult.success;
    }

    ComResult getOpacity(out double value) @safe pure nothrow
    {
        value = _opacity;
        return ComResult.success;
    }

    ComResult setOpacity(double opacity) nothrow
    {
        if (!ptr)
        {
            return ComResult.error("Texture2d opacity change error: texture is null");
        }

        _opacity = opacity;
        //TODO setColor with alpha
        if (!SDL_SetTextureAlphaMod(ptr, cast(ubyte)(255 * opacity)))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    override protected bool disposePtr() nothrow
    {
        if (ptr)
        {
            SDL_DestroyTexture(ptr);
            return true;
        }
        return false;
    }
}
