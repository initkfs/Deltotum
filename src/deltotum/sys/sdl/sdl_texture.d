module deltotum.sys.sdl.sdl_texture;

// dfmt off
version(SdlBackend):
// dfmt on

import deltotum.com.platforms.results.com_result : ComResult;
import deltotum.com.graphics.com_texture : ComTexture;
import deltotum.sys.sdl.base.sdl_object_wrapper : SdlObjectWrapper;
import deltotum.sys.sdl.sdl_renderer : SdlRenderer;
import deltotum.com.graphics.com_surface : ComSurface;
import deltotum.com.graphics.com_blend_mode : ComBlendMode;

import deltotum.math.shapes.rect2d : Rect2d;
import deltotum.math.geom.flip : Flip;

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
        void* ptr;
        if (const err = surface.nativePtr(ptr))
        {
            return err;
        }
        SDL_Surface* surfPtr = cast(SDL_Surface*) ptr;
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

    ComResult setPixelColor(uint* ptr, ubyte r, ubyte g, ubyte b, ubyte aNorm) nothrow
    {
        SDL_PixelFormat* format;
        if (const formatErr = getFormat(format))
        {
            return formatErr;
        }
        const newColor = SDL_MapRGBA(format, r, g, b, aNorm);
        *ptr = newColor;
        return ComResult.success;
    }

    ComResult getPixelColor(int x, int y, out ubyte r, out ubyte g, out ubyte b, out ubyte aNorm) nothrow
    {
        uint* pixel;
        if (const err = getPixel(x, y, pixel))
        {
            return err;
        }
        return getPixelColor(pixel, r, g, b, aNorm);
    }

    ComResult getPixelColor(uint* ptr, out ubyte r, out ubyte g, out ubyte b, out ubyte aNorm) @nogc nothrow
    {
        SDL_PixelFormat* format;
        if (const formatErr = getFormat(format))
        {
            return formatErr;
        }
        SDL_GetRGBA(*ptr, format, &r, &g, &b, &aNorm);
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

    ComResult draw(Rect2d textureBounds, Rect2d destBounds, double angle = 0, Flip flip = Flip
            .none)
    {
        SDL_Rect srcRect;
        srcRect.x = cast(int) textureBounds.x;
        srcRect.y = cast(int) textureBounds.y;
        srcRect.w = cast(int) textureBounds.width;
        srcRect.h = cast(int) textureBounds.height;

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
        return renderer.copyEx(this, &srcRect, &destRect, angle, null, sdlFlip);
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

        if (const err = newTexture.setBlendModeBlend)
        {
            return err;
        }

        if (const err = newTexture.setRendererTarget)
        {
            return err;
        }

        Rect2d srcRect = {0, 0, width, height};
        Rect2d destRect = {0, 0, width, height};

        if (const err = draw(srcRect, destRect))
        {
            return err;
        }
        if (const err = resetRendererTarget)
        {
            return err;
        }
        toTexture = newTexture;
        return ComResult.success;
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
