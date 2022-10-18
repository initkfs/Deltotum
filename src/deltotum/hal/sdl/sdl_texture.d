module deltotum.hal.sdl.sdl_texture;

import deltotum.hal.result.hal_result : HalResult;
import deltotum.hal.sdl.base.sdl_object_wrapper : SdlObjectWrapper;
import deltotum.hal.sdl.sdl_renderer : SdlRenderer;
import deltotum.hal.sdl.sdl_surface : SdlSurface;

import deltotum.math.shapes.rect2d : Rect2d;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlTexture : SdlObjectWrapper!SDL_Texture
{
    //TODO move to RgbaTexture
    private
    {
        double _opacity;
    }

    this(SDL_Texture* ptr)
    {
        super(ptr);
    }

    this()
    {
        super();
    }

    HalResult query(int* width, int* height, uint* format, SDL_TextureAccess* access) @nogc nothrow
    {
        immutable int zeroOrErrorCode = SDL_QueryTexture(ptr, format, access, width, height);
        return HalResult(zeroOrErrorCode);
    }

    int getSize(int* width, int* height) @nogc nothrow
    {
        return query(width, height, null, null);
    }

    void create(SdlRenderer renderer, uint format,
        SDL_TextureAccess access, int w,
        int h)
    {
        ptr = SDL_CreateTexture(renderer.getSdlObject, format, access, w, h);
        if (ptr is null)
        {
            string error = "Unable create texture.";
            if (const err = getError)
            {
                error ~= err;
            }
            throw new Exception(error);
        }
    }

    void createRGBA(SdlRenderer renderer, int width, int height)
    {
        create(renderer, SDL_PIXELFORMAT_RGBA32,
            SDL_TextureAccess.SDL_TEXTUREACCESS_TARGET, width,
            height);
    }

    //SDL_BlendMode
    void setBlendModeBlend() @nogc nothrow
    {
        SDL_SetTextureBlendMode(ptr, SDL_BLENDMODE_BLEND);
    }

    void fromRenderer(SdlRenderer renderer, SdlSurface surface)
    {
        ptr = SDL_CreateTextureFromSurface(renderer.getSdlObject, surface.getSdlObject);
        if (ptr is null)
        {
            string error = "Unable create texture from renderer and surface.";
            if (const err = getError)
            {
                error ~= err;
            }
            //TODO or tryParse\return bool?
            throw new Exception(error);
        }
        SDL_SetTextureBlendMode(ptr, SDL_BLENDMODE_BLEND);
    }

    HalResult changeOpacity(double opacity) @nogc nothrow
    {
        immutable int zeroOrErrorCode = SDL_SetTextureAlphaMod(ptr, cast(ubyte)(255 * opacity));
        return HalResult(zeroOrErrorCode);
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

    @property double opacity() @safe pure nothrow
    {
        return _opacity;
    }

    @property void opacity(double opacity) @nogc nothrow
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
