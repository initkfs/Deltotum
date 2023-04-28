module deltotum.sys.sdl.sdl_texture;

// dfmt off
version(SdlBackend):
// dfmt on

import deltotum.com.results.platform_result : PlatformResult;
import deltotum.sys.sdl.base.sdl_object_wrapper : SdlObjectWrapper;
import deltotum.sys.sdl.sdl_renderer : SdlRenderer;
import deltotum.sys.sdl.sdl_surface : SdlSurface;

import deltotum.math.shapes.rect2d : Rect2d;
import deltotum.kit.display.flip : Flip;

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

    PlatformResult query(int* width, int* height, uint* format, SDL_TextureAccess* access) @nogc nothrow
    {
        if (!ptr)
        {
            return PlatformResult.error("Texture query error: texture ponter is null");
        }
        const int zeroOrErrorCode = SDL_QueryTexture(ptr, format, access, width, height);
        return PlatformResult(zeroOrErrorCode);
    }

    PlatformResult getSize(int* width, int* height) @nogc nothrow
    {
        return query(width, height, null, null);
    }

    void setRendererTarget()
    {
        SDL_SetRenderTarget(renderer.getObject, ptr);
    }

    void resetRendererTarget()
    {
        SDL_SetRenderTarget(renderer.getObject, null);
    }

    PlatformResult create(uint format,
        SDL_TextureAccess access, int w,
        int h)
    {
        if (ptr)
        {
            destroyPtr;
        }

        ptr = SDL_CreateTexture(renderer.getObject, format, access, w, h);
        if (ptr is null)
        {
            string error = "Unable create texture.";
            if (const err = getError)
            {
                error ~= err;
            }
            return PlatformResult.error(error);
        }

        return PlatformResult.success;
    }

    PlatformResult getColor(ubyte* r, ubyte* g, ubyte* b)
    {
        const int zeroOrErrorCode = SDL_GetTextureColorMod(ptr, r, g, b);
        return PlatformResult(zeroOrErrorCode);
    }

    PlatformResult setColor(ubyte r, ubyte g, ubyte b)
    {
        const int zeroOrErrorCode = SDL_SetTextureColorMod(ptr, r, g, b);
        return PlatformResult(zeroOrErrorCode);
    }

    PlatformResult createRGBA(int width, int height)
    {
        return create(SDL_PIXELFORMAT_RGBA32,
            SDL_TextureAccess.SDL_TEXTUREACCESS_TARGET, width,
            height);
    }

    PlatformResult setBlendModeBlend() @nogc nothrow
    {
        const int zeroOrErrorCode = SDL_SetTextureBlendMode(ptr, SDL_BLENDMODE_BLEND);
        return PlatformResult(zeroOrErrorCode);
    }

    PlatformResult setBlendModeNone() @nogc nothrow
    {
        const int zeroOrErrorCode = SDL_SetTextureBlendMode(ptr, SDL_BLENDMODE_NONE);
        return PlatformResult(zeroOrErrorCode);
    }

    PlatformResult fromSurface(SdlSurface surface)
    {
        if (ptr)
        {
            destroyPtr;
        }

        ptr = SDL_CreateTextureFromSurface(renderer.getObject, surface.getObject);
        if (ptr is null)
        {
            string error = "Unable create texture from renderer and surface.";
            if (const err = getError)
            {
                error ~= err;
            }
            return PlatformResult.error(error);
        }
        SDL_SetTextureBlendMode(ptr, SDL_BLENDMODE_BLEND);
        return PlatformResult.success;
    }

    PlatformResult changeOpacity(double opacity) @nogc nothrow
    {
        if (!ptr)
        {
            return PlatformResult.error("Texture opacity change error: texture is null");
        }
        const int zeroOrErrorCode = SDL_SetTextureAlphaMod(ptr, cast(ubyte)(255 * opacity));
        return PlatformResult(zeroOrErrorCode);
    }

    PlatformResult draw(Rect2d textureBounds, Rect2d destBounds, double angle = 0, Flip flip = Flip
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

    override protected bool destroyPtr() @nogc nothrow
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
