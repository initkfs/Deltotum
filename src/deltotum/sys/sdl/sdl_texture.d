module deltotum.sys.sdl.sdl_texture;

// dfmt off
version(SdlBackend):
// dfmt on

import deltotum.com.platforms.results.com_result : ComResult;
import deltotum.sys.sdl.base.sdl_object_wrapper : SdlObjectWrapper;
import deltotum.sys.sdl.sdl_renderer : SdlRenderer;
import deltotum.sys.sdl.sdl_surface : SdlSurface;

import deltotum.math.shapes.rect2d : Rect2d;
import deltotum.math.geom.flip : Flip;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlTexture : SdlObjectWrapper!SDL_Texture
{
    //TODO move to RgbaTexture
    private
    {
        double _opacity = 0;
        SdlRenderer renderer;
    }

    protected
    {
        //TODO getDepth?
        int depth = 32;
    }

    this(SdlRenderer renderer)
    {
        assert(renderer);
        this.renderer = renderer;
    }

    protected this(SDL_Texture* ptr, SdlRenderer renderer)
    {
        super(ptr);
        this.renderer = renderer;
    }

    //TODO replace with out
    ComResult query(int* width, int* height, uint* format, SDL_TextureAccess* access) @nogc nothrow
    {
        if (!ptr)
        {
            return ComResult.error("Texture query error: texture ponter is null");
        }
        const int zeroOrErrorCode = SDL_QueryTexture(ptr, format, access, width, height);
        return ComResult(zeroOrErrorCode);
    }

    ComResult getFormat(ref SDL_PixelFormat* format)
    {
        uint formatPtr;
        if (const err = query(null, null, &formatPtr, null))
        {
            return err;
        }
        format = SDL_AllocFormat(formatPtr);
        return ComResult.success;
    }

    ComResult getSize(int* width, int* height) @nogc nothrow
    {
        return query(width, height, null, null);
    }

    void setRendererTarget()
    {
        const zeroOrErr = SDL_SetRenderTarget(renderer.getObject, ptr);
        if (zeroOrErr != 0)
        {
            import std.string : fromStringz;

            throw new Exception(getError.fromStringz.idup);
        }
    }

    void resetRendererTarget()
    {
        const zeroOrErr = SDL_SetRenderTarget(renderer.getObject, null);
        import std.string : fromStringz;

        if (zeroOrErr != 0)
        {
            throw new Exception(getError.fromStringz.idup);
        }
    }

    ComResult create(uint format,
        SDL_TextureAccess access, int w,
        int h)
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

    ComResult getColorAlpha(ubyte* alpha)
    {
        const int zeroOrErrorCode = SDL_GetTextureAlphaMod(ptr, alpha);
        return ComResult(zeroOrErrorCode);
    }

    ComResult setColorAlpha(ubyte alpha)
    {
        const int zeroOrErrorCode = SDL_SetTextureAlphaMod(ptr, alpha);
        return ComResult(zeroOrErrorCode);
    }

    ComResult getColor(ubyte* r, ubyte* g, ubyte* b)
    {
        const int zeroOrErrorCode = SDL_GetTextureColorMod(ptr, r, g, b);
        return ComResult(zeroOrErrorCode);
    }

    ComResult setColor(ubyte r, ubyte g, ubyte b)
    {
        const int zeroOrErrorCode = SDL_SetTextureColorMod(ptr, r, g, b);
        return ComResult(zeroOrErrorCode);
    }

    ComResult createMutableRGBA32(int width, int height)
    {
        return create(SDL_PIXELFORMAT_RGBA32,
            SDL_TextureAccess.SDL_TEXTUREACCESS_STREAMING, width,
            height);
    }

    ComResult createRGBA(int width, int height)
    {
        return create(SDL_PIXELFORMAT_RGBA32,
            SDL_TextureAccess.SDL_TEXTUREACCESS_TARGET, width,
            height);
    }

    ComResult lock(ref uint* pixels, out int pitch) @nogc nothrow
    {
        assert(ptr);
        //pitch == length row of pixels in bytes
        const zeroOrErrorCode = SDL_LockTexture(ptr, null, cast(void**)&pixels, &pitch);
        return ComResult(zeroOrErrorCode, getError);
    }

    ComResult unlock() @nogc nothrow
    {
        SDL_UnlockTexture(ptr);
        return ComResult.success;
    }

    ComResult changeColor(uint x, uint y, uint* pixels, uint pitch, ubyte r, ubyte g, ubyte b, ubyte a) @nogc nothrow
    {
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
        const pixelPosition = (y * (pitch / int.sizeof) + x);

        pixels[pixelPosition] = color;

        return ComResult.success;
    }

    ComResult pixel(uint x, uint y, uint* pixels, uint pitch, out uint* pixel) @nogc nothrow
    {
        const pixelPosition = (y * (pitch / int.sizeof) + x);
        pixel = &pixels[pixelPosition];
        return ComResult.success;
    }

    ComResult setBlendModeBlend() @nogc nothrow
    {
        const int zeroOrErrorCode = SDL_SetTextureBlendMode(ptr, SDL_BLENDMODE_BLEND);
        return ComResult(zeroOrErrorCode);
    }

    ComResult setBlendModeNone() @nogc nothrow
    {
        const int zeroOrErrorCode = SDL_SetTextureBlendMode(ptr, SDL_BLENDMODE_NONE);
        return ComResult(zeroOrErrorCode);
    }

    ComResult fromSurface(SdlSurface surface)
    {
        if (ptr)
        {
            disposePtr;
        }
        return fromSurfacePtr(surface.getObject);
    }

    ComResult fromSurfacePtr(SDL_Surface* surface)
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

    ComResult resize(double newWidth, double newHeight)
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

        setRendererTarget;
        const int zeroOrErrRead = SDL_RenderReadPixels(renderer.getObject, &srcRect, format, tempSrc.pixels, tempSrc
                .pitch);
        if (zeroOrErrRead != 0)
        {
            return ComResult(zeroOrErrRead, getError);
        }

        resetRendererTarget;

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

    ComResult changeOpacity(double opacity) @nogc nothrow
    {
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

    SdlTexture copy()
    {
        SdlTexture newTexture = new SdlTexture(renderer);
        int width, height;
        if(const err = getSize(&width, &height)){
            throw new Exception(err.toString);
        }
        if (const err = newTexture.createRGBA(width, height))
        {
            //TODO return error;
            throw new Exception(err.toString);
        }
        
        if(const err = newTexture.setBlendModeBlend){
            throw new Exception(err.toString);
        }

        newTexture.setRendererTarget;

        Rect2d srcRect = {0, 0, width, height};
        Rect2d destRect = {0, 0, width, height};

        if (const err = draw(srcRect, destRect))
        {
            throw new Exception(err.toString);
        }
        resetRendererTarget;
        return newTexture;
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

    void opacity(double opacity) @nogc nothrow
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

}
