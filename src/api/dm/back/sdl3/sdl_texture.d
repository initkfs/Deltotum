module api.dm.back.sdl3.sdl_texture;

// dfmt off
version(SdlBackend):
// dfmt on

import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.com.graphic.com_texture : ComTexture;
import api.dm.com.com_native_ptr : ComNativePtr;
import api.dm.back.sdl3.base.sdl_object_wrapper : SdlObjectWrapper;
import api.dm.back.sdl3.sdl_renderer : SdlRenderer;
import api.dm.com.graphic.com_surface : ComSurface;
import api.dm.com.graphic.com_blend_mode : ComBlendMode;
import api.dm.com.graphic.com_texture : ComTextureScaleMode;

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
        SdlRenderer renderer;

        double _opacity = 0;
        bool locked;
        int pitch;
        uint* pixelPtr;

        SDL_Texture* lastRendererTarget;
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

    ComResult createUnsafe(void* newPtr) nothrow
    {
        return create(cast(SDL_Texture*) newPtr);
    }

    ComResult create(SDL_Texture* texture) nothrow => setWithDispose(texture);

    ComResult create(SDL_PixelFormat format, SDL_TextureAccess access, int w, int h) nothrow
    {
        assert(renderer);

        auto newPtr = SDL_CreateTexture(renderer.getObject, format, access, w, h);
        if (!newPtr)
        {
            return getErrorRes("Error creating new SDL texture");
        }

        return setWithDispose(newPtr);
    }

    ComResult createRGBA32(int width, int height) nothrow
    {
        //alias SDL_PIXELFORMAT_RGBA32 = SDL_PIXELFORMAT_ABGR8888;
        return create(SDL_PIXELFORMAT_RGBA32,
            SDL_TextureAccess.SDL_TEXTUREACCESS_STATIC, width,
            height);
    }

    ComResult createABGR32(int width, int height) nothrow
    {
        return create(SDL_PIXELFORMAT_ABGR32,
            SDL_TextureAccess.SDL_TEXTUREACCESS_STATIC, width,
            height);
    }

    ComResult createARGB32(int width, int height) nothrow
    {
        return create(SDL_PIXELFORMAT_ARGB32,
            SDL_TextureAccess.SDL_TEXTUREACCESS_STATIC, width,
            height);
    }

    ComResult createMutRGBA32(int width, int height) nothrow
    {
        return create(SDL_PIXELFORMAT_RGBA32,
            SDL_TextureAccess.SDL_TEXTUREACCESS_STREAMING, width,
            height);
    }

    ComResult createMutABGR32(int width, int height) nothrow
    {
        return create(SDL_PIXELFORMAT_ABGR32,
            SDL_TextureAccess.SDL_TEXTUREACCESS_STREAMING, width,
            height);
    }

    ComResult createMutBGRA32(int width, int height) nothrow
    {
        return create(SDL_PIXELFORMAT_BGRA32,
            SDL_TextureAccess.SDL_TEXTUREACCESS_STREAMING, width,
            height);
    }

    ComResult createMutARGB32(int width, int height) nothrow
    {
        return create(SDL_PIXELFORMAT_ARGB32,
            SDL_TextureAccess.SDL_TEXTUREACCESS_STREAMING, width,
            height);
    }

    ComResult createTargetRGBA32(int width, int height) nothrow
    {
        return create(SDL_PIXELFORMAT_RGBA32,
            SDL_TextureAccess.SDL_TEXTUREACCESS_TARGET, width,
            height);
    }

    ComResult createMutYV(int width, int height) nothrow
    {
        return create(SDL_PIXELFORMAT_IYUV,
            SDL_TextureAccess.SDL_TEXTUREACCESS_STREAMING, width,
            height);
    }

    ComResult create(ComSurface surface) nothrow
    {
        assert(surface, "Surface for new SDL texture must not be null");
        ComNativePtr newPtr;
        if (const err = surface.nativePtr(newPtr))
        {
            return err;
        }

        ComNativePtr surfPtr;
        if (const err = surface.nativePtr(surfPtr))
        {
            return err;
        }

        SDL_Surface* sptr = surfPtr.castSafe!(SDL_Surface*);
        return create(sptr);
    }

    ComResult create(SDL_Surface* surface) nothrow
    {
        assert(surface, "Surface ptr for new SDL texture must not be null");
        assert(renderer);

        auto newPtr = SDL_CreateTextureFromSurface(renderer.getObject, surface);
        if (!newPtr)
        {
            return getErrorRes("Unable create SDL texture from renderer and surface.");
        }

        if (const err = setWithDispose(newPtr))
        {
            return err;
        }

        //TODO side effect 
        if (!SDL_SetTextureBlendMode(ptr, SDL_BLENDMODE_BLEND))
        {
            return getErrorRes("Error setting blend mode on new SDL texture from surface");
        }
        return ComResult.success;
    }

    ComResult isCreated(out bool created) nothrow
    {
        created = ptr !is null;
        return ComResult.success;
    }

    protected ComResult query(int* width, int* height, SDL_PixelFormat* format, SDL_TextureAccess* access) nothrow
    {
        if (!ptr)
        {
            return ComResult.error("SDL texture query error: texture ponter is null");
        }

        SDL_PropertiesID propId = SDL_GetTextureProperties(ptr);
        if (propId == 0)
        {
            return getErrorRes("Error getting SDL texture properties for query");
        }

        if (format)
        {
            *format = cast(SDL_PixelFormat) SDL_GetNumberProperty(propId, SDL_PROP_TEXTURE_FORMAT_NUMBER.ptr, 0);
        }
        if (access)
        {
            *access = cast(SDL_TextureAccess) SDL_GetNumberProperty(propId, SDL_PROP_TEXTURE_ACCESS_NUMBER.ptr, 0);
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

    SDL_PixelFormat getPixelFormat() nothrow
    {
        assert(ptr);
        return ptr.format;
    }

    ComResult getFormat(out uint format) nothrow
    {
        format = getPixelFormat;
        return ComResult.success;
    }

    ComResult getPixelRowLenBytes(out int pitch) nothrow
    {
        if (!locked)
        {
            return ComResult.error("SDL texture not locked for pitch");
        }
        pitch = this.pitch;
        return ComResult.success;
    }

    SDL_PixelFormatDetails* getPixelFormatDetails(SDL_PixelFormat format) nothrow
    {
        assert(ptr);
        return SDL_GetPixelFormatDetails(format);
    }

    ComResult getFormatDetails(SDL_PixelFormat format, out SDL_PixelFormatDetails* details) nothrow
    {
        assert(ptr);

        details = getPixelFormatDetails(format);
        if (!details)
        {
            return getErrorRes("Error getting pixel format details from SDL texture");
        }
        return ComResult.success;
    }

    ComResult getRendererTarget(out SDL_Texture* target) nothrow
    {
        assert(renderer);
        target = SDL_GetRenderTarget(renderer.getObject);
        return ComResult.success;
    }

    ComResult setRendererTarget() nothrow
    {
        assert(ptr);
        assert(renderer);

        if (lastRendererTarget)
        {
            return ComResult.error("Error setting renderer target: last target not null");
        }

        if (const err = getRendererTarget(lastRendererTarget))
        {
            return err;
        }

        if (!SDL_SetRenderTarget(renderer.getObject, ptr))
        {
            return getErrorRes("Error setting render target SDL texture");
        }
        return ComResult.success;
    }

    ComResult restoreRendererTarget() nothrow
    {
        assert(renderer);

        SDL_Texture* target;
        if (lastRendererTarget)
        {
            target = lastRendererTarget;
            lastRendererTarget = null;
        }

        if (!SDL_SetRenderTarget(renderer.getObject, target))
        {
            return getErrorRes("Error restore renderer target for SDL texture");
        }
        return ComResult.success;
    }

    ComResult getSize(out int width, out int height) nothrow
    {
        assert(ptr);

        width = ptr.w;
        height = ptr.h;

        return ComResult.success;
    }

    ComResult setSize(int newWidth, int newHeight) nothrow
    {
        assert(ptr);
        assert(renderer);

        if (newWidth <= 0)
        {
            return ComResult.error("SDL texture new width must be positive number");
        }

        if (newHeight <= 0)
        {
            return ComResult.error("SDL texture new height must be positive number");
        }
        //TODO remove duplication
        SDL_Rect srcRect, dstRect;

        dstRect.x = 0;
        dstRect.y = 0;
        dstRect.w = newWidth;
        dstRect.h = newHeight;

        int textureWidth, textureHeight;
        SDL_PixelFormat format;
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
            return getErrorRes("Error creating temp SDL surface for resizing");
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
            return getErrorRes("Error blitting SDL surface for resizing SDL texture");
        }

        if (const err = create(tempDst))
        {
            return err;
        }

        return ComResult.success;
    }

    ComResult getAlphaMod(out ubyte alpha) nothrow
    {
        assert(ptr);

        if (!SDL_GetTextureAlphaMod(ptr, &alpha))
        {
            return getErrorRes("Error getting SDL texture alpha mod");
        }
        return ComResult.success;
    }

    protected ComResult setAlphaMod(ubyte alpha) nothrow
    {
        assert(ptr);

        if (!SDL_SetTextureAlphaMod(ptr, alpha))
        {
            return getErrorRes("Error setting SDL texture alpha mod");
        }
        return ComResult.success;
    }

    ComResult setBlendMode(ComBlendMode mode) nothrow
    {
        assert(ptr);

        SDL_BlendMode newMode = toNativeBlendMode(mode);
        if (!SDL_SetTextureBlendMode(ptr, newMode))
        {
            return getErrorRes("Error setting SDL texture blend mode");
        }
        return ComResult.success;
    }

    ComResult setBlendModeBlend() nothrow => setBlendMode(ComBlendMode.blend);
    ComResult setBlendModeNone() nothrow => setBlendMode(ComBlendMode.none);

    ComResult getOpacity(out double value) nothrow
    {
        assert(ptr);

        if (_opacity != 0)
        {
            value = _opacity;
            return ComResult.success;
        }
        ubyte alphaMod;
        if (const err = getAlphaMod(alphaMod))
        {
            return err;
        }
        value = (cast(double) alphaMod) / ubyte.max;
        return ComResult.success;
    }

    ComResult setOpacity(double opacity) nothrow
    {
        if (!ptr)
        {
            return ComResult.error("Error setting SDL texture opacity: texture is null");
        }

        _opacity = opacity;
        return setAlphaMod(cast(ubyte)(ubyte.max * opacity));
    }

    ComResult getScaleMode(out ComTextureScaleMode mode) nothrow
    {
        assert(ptr);

        SDL_ScaleMode oldMode;
        if (!SDL_GetTextureScaleMode(ptr, &oldMode))
        {
            return getErrorRes("Error getting SDL texture scale mode");
        }
        mode = fromSdlMode(oldMode);
        return ComResult.success;
    }

    ComResult setScaleMode(ComTextureScaleMode mode) nothrow
    {
        assert(ptr);

        const nativeMode = toSdlMode(mode);
        if (!SDL_SetTextureScaleMode(ptr, nativeMode))
        {
            return getErrorRes("Error setting SDL texture scale mode");
        }
        return ComResult.success;
    }

    ComResult getColor(out ubyte r, out ubyte g, out ubyte b, out ubyte a) nothrow
    {
        assert(ptr);

        if (!SDL_GetTextureColorMod(ptr, &r, &g, &b))
        {
            return getErrorRes("Error getting SDL texture color mod");
        }
        return getAlphaMod(a);
    }

    ComResult setColor(ubyte r, ubyte g, ubyte b, ubyte a) nothrow
    {
        assert(ptr);

        if (!SDL_SetTextureColorMod(ptr, r, g, b))
        {
            return getErrorRes("Error setting SDL texture color mod");
        }
        return setAlphaMod(a);
    }

    ComResult lock() nothrow
    {
        assert(ptr);
        assert(!locked);
        if (!SDL_LockTexture(ptr, null, cast(void**)&pixelPtr, &pitch))
        {
            return getErrorRes("Error lock SDL texture");
        }

        locked = true;
        return ComResult.success;
    }

    ComResult lockToSurface(SDL_Rect* bounds, SDL_Surface* surface) nothrow
    {
        assert(ptr);
        assert(!locked);

        if (!SDL_LockTextureToSurface(ptr, bounds, &surface))
        {
            return getErrorRes("Error locking texuture to surface");
        }

        locked = true;
        return ComResult.success;
    }

    ComResult lockToSurface(Rect2d src, ComSurface surf) nothrow
    {
        assert(surf);
        SDL_Rect bounds = toSdlRect(src);
        SDL_Surface* newSurfPtr;
        if (const err = lockToSurface(&bounds, newSurfPtr))
        {
            return err;
        }
        assert(newSurfPtr);
        return surf.create(ComNativePtr(newSurfPtr));
    }

    ComResult lockToSurface(ComSurface surf) nothrow
    {
        assert(surf);
        SDL_Surface* newSurfPtr;
        if (const err = lockToSurface(null, newSurfPtr))
        {
            return err;
        }
        assert(newSurfPtr);
        return surf.create(ComNativePtr(newSurfPtr));
    }

    ComResult unlock() nothrow
    {
        assert(ptr);
        assert(locked);

        SDL_UnlockTexture(ptr);

        //TODO check unlock?
        locked = false;
        pixelPtr = null;
        pitch = 0;
        return ComResult.success;
    }

    ComResult update(Rect2d rect, void* pixels, int pitch) nothrow
    {
        assert(ptr);

        if (!locked)
        {
            return ComResult.error("SDL texture not locked for update");
        }

        SDL_Rect bounds = {0, 0, cast(int) rect.width, cast(int) rect.height};

        const isUpdate = SDL_UpdateTexture(ptr,
            &bounds, cast(void*) pixelPtr, pitch);
        if (!isUpdate)
        {
            return getErrorRes("Error updating SDL texture");
        }
        return ComResult.success;
    }

    ComResult getPixels(out void* pixels)
    {
        assert(ptr);
        assert(pixels);

        if (!locked)
        {
            return ComResult.error("SDL texture not locked for getting pixels");
        }
        pixels = cast(void*) pixelPtr;
        return ComResult.success;
    }

    ComResult getPixel(uint x, uint y, out uint* pixel) nothrow
    {
        assert(ptr);
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
        SDL_PixelFormat formatValue = getPixelFormat;

        SDL_PixelFormatDetails* details;
        if (const err = getFormatDetails(cast(SDL_PixelFormat) formatValue, details))
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
        SDL_PixelFormat format = getPixelFormat;

        SDL_PixelFormatDetails* details;
        if (const err = getFormatDetails(format, details))
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
        SDL_PixelFormat format = getPixelFormat;
        SDL_PixelFormatDetails* details;
        if (const err = getFormatDetails(format, details))
        {
            return err;
        }

        SDL_GetRGBA(*ptr, details, null, &r, &g, &b, &aByte);
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
        return renderer.renderTextureEx(t, &srcRect, &destRect, angle, rotateCenter, sdlFlip);
    }

    ComResult copyToNew(out ComTexture toTexture)
    {
        assert(ptr);

        SdlTexture newTexture;
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

        auto format = getPixelFormat;

        if (const err = newTexture.create(format, SDL_TEXTUREACCESS_TARGET, width, height))
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

    ComResult nativePtr(out ComNativePtr nptr) nothrow
    {
        assert(ptr);
        nptr = ComNativePtr(ptr);
        return ComResult.success;
    }

    ComResult nativePtr(out void* tptr)
    {
        assert(ptr);
        tptr = cast(void*) ptr;
        return ComResult.success;
    }

    ComResult isLocked(out bool value) nothrow
    {
        value = locked;
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
