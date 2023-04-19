module deltotum.sdl.sdl_texture;

// dfmt off
version(SdlBackend):
// dfmt on

import deltotum.platform.results.platform_result : PlatformResult;
import deltotum.sdl.base.sdl_object_wrapper : SdlObjectWrapper;
import deltotum.sdl.sdl_renderer : SdlRenderer;
import deltotum.sdl.sdl_surface : SdlSurface;

import deltotum.maths.shapes.rect2d : Rect2d;

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
    }

    this()
    {
        super();
    }

    this(SDL_Texture* ptr)
    {
        super(ptr);
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

    PlatformResult create(SdlRenderer renderer, uint format,
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

    PlatformResult createRGBA(SdlRenderer renderer, int width, int height)
    {
        return create(renderer, SDL_PIXELFORMAT_RGBA32,
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

    PlatformResult fromRenderer(SdlRenderer renderer, SdlSurface surface)
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
