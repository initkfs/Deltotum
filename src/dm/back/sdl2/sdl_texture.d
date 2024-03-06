module dm.back.sdl2.sdl_texture;

// dfmt off
version(SdlBackend):
// dfmt on

import dm.com.platforms.results.com_result : ComResult;
import dm.com.graphics.com_texture : ComTexture;
import dm.back.sdl2.base.sdl_object_wrapper : SdlObjectWrapper;
import dm.back.sdl2.sdl_renderer : SdlRenderer;
import dm.com.graphics.com_surface : ComSurface;
import dm.com.graphics.com_blend_mode : ComBlendMode;
import dm.com.graphics.com_texture_scale_mode : ComTextureScaleMode;

import dm.math.rect2d : Rect2d;
import dm.math.flip : Flip;

import bindbc.sdl;

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
    }

    protected
    {
        //TODO getDepth?
        int depth = 32;
    }

    this(SdlRenderer renderer) pure
    {
        assert(renderer);
        this.renderer = renderer;
    }

    protected this(SDL_Texture* ptr, SdlRenderer renderer)
    {
        super(ptr);
        this.renderer = renderer;
    }

    ComResult fromSurface(ComSurface surface) nothrow
    {
        if (ptr)
        {
            disposePtr;
        }
        //TODO unsafe cast
        void* newPtr;
        if (const err = surface.nativePtr(newPtr))
        {
            return err;
        }
        SDL_Surface* surfPtr = cast(SDL_Surface*) newPtr;
        return fromSurfacePtr(surfPtr);
    }

    ComResult fromSurfacePtr(SDL_Surface* surface) nothrow
    {
        if (ptr)
        {
            disposePtr;
        }

        ptr = SDL_CreateTextureFromSurface(renderer.getObject, surface);
        if (ptr is null)
        {
            string error = "Unable create texture from renderer and surface.";
            if (const err = getError)
            {
                error ~= err;
            }
            return ComResult.error(error);
        }
        //TODO side effect 
        SDL_SetTextureBlendMode(ptr, SDL_BLENDMODE_BLEND);
        return ComResult.success;
    }

    ComResult recreatePtr(void* newPtr) nothrow
    {
        if (ptr)
        {
            disposePtr;
        }
        ptr = cast(SDL_Texture*) newPtr;
        return ComResult.success;
    }

    protected ComResult query(int* width, int* height, uint* format, SDL_TextureAccess* access) @nogc nothrow
    {
        if (!ptr)
        {
            return ComResult.error("Texture query error: texture ponter is null");
        }
        const int zeroOrErrorCode = SDL_QueryTexture(ptr, format, access, width, height);
        return ComResult(zeroOrErrorCode);
    }

    protected ComResult getFormat(out SDL_PixelFormat* format) @nogc nothrow
    {
        uint formatPtr;
        if (const err = query(null, null, &formatPtr, null))
        {
            return err;
        }
        format = SDL_AllocFormat(formatPtr);
        return ComResult.success;
    }

    ComResult getSize(out int width, out int height) nothrow
    {
        return query(&width, &height, null, null);
    }

    ComResult setRendererTarget() nothrow
    {
        const zeroOrErr = SDL_SetRenderTarget(renderer.getObject, ptr);
        return ComResult(zeroOrErr);
    }

    ComResult resetRendererTarget() nothrow
    {
        const zeroOrErr = SDL_SetRenderTarget(renderer.getObject, null);
        return ComResult(zeroOrErr);
    }

    protected ComResult create(uint format,
        SDL_TextureAccess access, int w,
        int h) nothrow
    {
        if (ptr)
        {
            disposePtr;
        }

        ptr = SDL_CreateTexture(renderer.getObject, format, access, w, h);
        if (ptr is null)
        {
            string error = "Unable create texture.";
            if (const err = getError)
            {
                error ~= err;
            }
            return ComResult.error(error);
        }

        return ComResult.success;
    }

    protected ComResult getAlphaMod(out ubyte alpha) nothrow
    {
        const int zeroOrErrorCode = SDL_GetTextureAlphaMod(ptr, &alpha);
        return ComResult(zeroOrErrorCode);
    }

    protected ComResult setAlphaMod(ubyte alpha) nothrow
    {
        const int zeroOrErrorCode = SDL_SetTextureAlphaMod(ptr, alpha);
        return ComResult(zeroOrErrorCode);
    }

    ComResult getColor(out ubyte r, out ubyte g, out ubyte b, out ubyte a) nothrow
    {
        const int zeroOrErrorCode = SDL_GetTextureColorMod(ptr, &r, &g, &b);
        if (zeroOrErrorCode != 0)
        {
            return ComResult(zeroOrErrorCode);
        }
        return getAlphaMod(a);
    }

    ComResult setColor(ubyte r, ubyte g, ubyte b, ubyte a) nothrow
    {
        const int zeroOrErrorCode = SDL_SetTextureColorMod(ptr, r, g, b);
        if (zeroOrErrorCode != 0)
        {
            return ComResult(zeroOrErrorCode);
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
        return create(SDL_PIXELFORMAT_RGBA32,
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

    ComResult lock() @nogc nothrow
    {
        assert(ptr);
        assert(!locked);
        const zeroOrErrorCode = SDL_LockTexture(ptr, null, cast(void**)&pixelPtr, &pitch);
        if (zeroOrErrorCode == 0)
        {
            locked = true;
            return ComResult.success;
        }
        return ComResult(zeroOrErrorCode, getError);
    }

    ComResult unlock() nothrow
    {
        assert(locked);
        SDL_UnlockTexture(ptr);
        locked = false;
        pixelPtr = null;
        pitch = 0;
        return ComResult.success;
    }

    ComResult getPitch(out int pitch) @nogc nothrow
    {
        if (!locked)
        {
            return ComResult.error("Texture not locked for pitch");
        }
        pitch = this.pitch;
        return ComResult.success;
    }

    ComResult getPixels(out void* pixels)
    {
        if (!locked)
        {
            return ComResult.error("Texture not locked for pixels");
        }
        pixels = cast(void*) pixelPtr;
        return ComResult.success;
    }

    ComResult update(Rect2d rect, void* pixels, int pitch) @nogc nothrow
    {
        if (!locked)
        {
            return ComResult.error("Texture not locked for update");
        }
        SDL_Rect bounds = {0, 0, cast(int) rect.width, cast(int) rect.height};
        const zeroOrErr = SDL_UpdateTexture(ptr,
            &bounds, cast(void*) pixelPtr, pitch);
        return ComResult(zeroOrErr);
    }

    ComResult getPixel(uint x, uint y, out uint* pixel) @nogc nothrow
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

        //TODO class field or SDL global cache?
        SDL_PixelFormat* format = SDL_AllocFormat(formatValue);
        if (!format)
        {
            return ComResult.error(getError);
        }

        Uint32 color = SDL_MapRGBA(format, r, g, b, a);
        const pixelPosition = (y * (pitch / pitch.sizeof) + x);

        pixelPtr[pixelPosition] = color;

        return ComResult.success;
    }

    ComResult setPixelColor(uint* ptr, ubyte r, ubyte g, ubyte b, ubyte aByte) nothrow
    {
        SDL_PixelFormat* format;
        if (const formatErr = getFormat(format))
        {
            return formatErr;
        }
        const newColor = SDL_MapRGBA(format, r, g, b, aByte);
        *ptr = newColor;
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

    ComResult getPixelColor(uint* ptr, out ubyte r, out ubyte g, out ubyte b, out ubyte aByte) @nogc nothrow
    {
        SDL_PixelFormat* format;
        if (const formatErr = getFormat(format))
        {
            return formatErr;
        }
        SDL_GetRGBA(*ptr, format, &r, &g, &b, &aByte);
        return ComResult.success;
    }

    ComResult setBlendMode(ComBlendMode mode) nothrow
    {
        SDL_BlendMode newMode = typeConverter.toNativeBlendMode(mode);
        const int zeroOrErrorCode = SDL_SetTextureBlendMode(ptr, newMode);
        return ComResult(zeroOrErrorCode);
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
        SDL_TextureAccess access;
        if (const err = query(&textureWidth, &textureHeight, &format, &access))
        {
            return err;
        }

        srcRect.x = 0;
        srcRect.y = 0;
        srcRect.w = textureWidth;
        srcRect.h = textureHeight;

        auto tempSrc = SDL_CreateRGBSurfaceWithFormat(0, srcRect.w, srcRect.h, depth, format);
        if (!tempSrc)
        {
            //TODO errors
            return ComResult(-2, getError);
        }
        scope (exit)
        {
            SDL_FreeSurface(tempSrc);
        }

        auto tempDst = SDL_CreateRGBSurfaceWithFormat(0, dstRect.w, dstRect.h, depth, format);
        if (!tempDst)
        {
            return ComResult(-3, getError);
        }

        scope (exit)
        {
            SDL_FreeSurface(tempDst);
        }

        if (const err = setRendererTarget)
        {
            return err;
        }
        const int zeroOrErrRead = SDL_RenderReadPixels(renderer.getObject, &srcRect, format, tempSrc.pixels, tempSrc
                .pitch);
        if (zeroOrErrRead != 0)
        {
            return ComResult(zeroOrErrRead, getError);
        }

        if (const err = resetRendererTarget)
        {
            return err;
        }

        const int zeroOrErrorCode = SDL_BlitScaled(tempSrc, &srcRect, tempDst, &dstRect);
        if (zeroOrErrorCode != 0)
        {
            return ComResult(zeroOrErrorCode);
        }

        if (const err = fromSurfacePtr(tempDst))
        {
            return err;
        }

        return ComResult.success;
    }

    ComResult changeOpacity(double opacity) nothrow
    {
        //TODO setColor with alpha
        if (!ptr)
        {
            return ComResult.error("Texture opacity change error: texture is null");
        }
        const int zeroOrErrorCode = SDL_SetTextureAlphaMod(ptr, cast(ubyte)(255 * opacity));
        return ComResult(zeroOrErrorCode);
    }

    ComResult draw(Rect2d srcBounds, Rect2d destBounds, double angle = 0, Flip flip = Flip
            .none)
    {
        return draw(this, srcBounds, destBounds, angle, flip);
    }

    ComResult draw(ComTexture other, Rect2d srcBounds, Rect2d destBounds, double angle = 0, Flip flip = Flip
            .none)
    {
        SDL_Rect srcRect;
        srcRect.x = cast(int) srcBounds.x;
        srcRect.y = cast(int) srcBounds.y;
        srcRect.w = cast(int) srcBounds.width;
        srcRect.h = cast(int) srcBounds.height;

        //SDL_Rect bounds = window.getScaleBounds;

        SDL_Rect destRect;
        destRect.x = cast(int)(destBounds.x); // + bounds.x);
        destRect.y = cast(int)(destBounds.y); // + bounds.y);
        destRect.w = cast(int) destBounds.width;
        destRect.h = cast(int) destBounds.height;

        //FIXME some texture sizes can crash when changing the angle
        //double newW = height * abs(math.sinDeg(angle)) + width * abs(math.cosDeg(angle));
        //double newH = height * abs(math.cosDeg(angle)) + width * abs(math.sinDeg(angle));

        //TODO move to helper
        SDL_RendererFlip sdlFlip;
        final switch (flip)
        {
            case Flip.none:
                sdlFlip = SDL_RendererFlip.SDL_FLIP_NONE;
                break;
            case Flip.horizontal:
                sdlFlip = SDL_RendererFlip.SDL_FLIP_HORIZONTAL;
                break;
            case Flip.vertical:
                sdlFlip = SDL_RendererFlip.SDL_FLIP_VERTICAL;
                break;
        }

        //https://discourse.libsdl.org/t/1st-frame-sdl-renderer-software-sdl-flip-horizontal-ubuntu-wrong-display-is-it-a-bug-of-sdl-rendercopyex/25924
        SdlTexture t = cast(SdlTexture) other;
        assert(t);
        SDL_Point* rotateCenter = null;
        return renderer.copyEx(t, &srcRect, &destRect, angle, rotateCenter, sdlFlip);
    }

    ComResult copy(out ComTexture toTexture)
    {
        ComTexture newTexture = new SdlTexture(renderer);
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

        if (const err = resetRendererTarget)
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

        if (const err = resetRendererTarget)
        {
            return err;
        }

        return ComResult.success;
    }

    //TODO type converter
    private ComTextureScaleMode fromSdlMode(SDL_ScaleMode m) nothrow
    {
        final switch (m) with (SDL_ScaleMode)
        {
            case SDL_ScaleModeNearest:
                return ComTextureScaleMode.speed;
            case SDL_ScaleModeLinear:
                return ComTextureScaleMode.balance;
            case SDL_ScaleModeBest:
                return ComTextureScaleMode.quality;
        }
    }

    //TODO type converter
    private SDL_ScaleMode toSdlMode(ComTextureScaleMode m) nothrow
    {
        final switch (m) with (ComTextureScaleMode)
        {
            case speed:
                return SDL_ScaleMode.SDL_ScaleModeNearest;
            case balance:
                return SDL_ScaleMode.SDL_ScaleModeLinear;
            case quality:
                return SDL_ScaleMode.SDL_ScaleModeBest;
        }
    }

    ComResult setScaleMode(ComTextureScaleMode mode) nothrow
    {
        const nativeMode = toSdlMode(mode);
        const zeroOrErr = SDL_SetTextureScaleMode(ptr, nativeMode);
        if (zeroOrErr != 0)
        {
            return ComResult(zeroOrErr);
        }
        return ComResult.success;
    }

    ComResult getScaleMode(out ComTextureScaleMode mode) nothrow
    {
        SDL_ScaleMode oldMode;
        const zeroOrErr = SDL_GetTextureScaleMode(ptr, &oldMode);
        if (zeroOrErr != 0)
        {
            return ComResult(zeroOrErr);
        }
        mode = fromSdlMode(oldMode);
        return ComResult.success;
    }

    ComResult nativePtr(out void* nptr) nothrow
    {
        assert(this.ptr);
        nptr = cast(void*) ptr;
        return ComResult.success;
    }

    bool isCreated() nothrow
    {
        return ptr !is null;
    }

    override protected bool disposePtr() @nogc nothrow
    {
        if (ptr)
        {
            SDL_DestroyTexture(ptr);
            return true;
        }
        return false;
    }

    double opacity() @safe pure nothrow
    {
        return _opacity;
    }

    void opacity(double opacity) nothrow
    {
        _opacity = opacity;
        if (ptr)
        {
            if (const err = changeOpacity(_opacity))
            {
                //TODO logging?
                return;
            }
        }
    }

    bool isLocked() nothrow
    {
        return locked;
    }

}
