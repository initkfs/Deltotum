module deltotum.hal.sdl.sdl_texture;

import deltotum.hal.sdl.base.sdl_object_wrapper : SdlObjectWrapper;
import deltotum.hal.sdl.sdl_renderer : SdlRenderer;
import deltotum.hal.sdl.sdl_surface : SdlSurface;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlTexture : SdlObjectWrapper!SDL_Texture
{
    //TODO move to Texture
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

    int query(int* width, int* height, uint* format, SDL_TextureAccess* access)
    {
        const int zeroOrErrorCode = SDL_QueryTexture(ptr, format, access, width, height);
        return zeroOrErrorCode;
    }

    int getSize(int* width, int* height)
    {
        return query(width, height, null, null);
    }

    void create(SdlRenderer renderer, uint format,
        SDL_TextureAccess access, int w,
        int h)
    {
        ptr = SDL_CreateTexture(renderer.getStruct, format, access, w, h);
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

    void fromRenderer(SdlRenderer renderer, SdlSurface surface)
    {
        ptr = SDL_CreateTextureFromSurface(renderer.getStruct, surface.getStruct);
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

    int changeOpacity(double opacity) @nogc nothrow
    {
        const int zeroOrErrorCode = SDL_SetTextureAlphaMod(ptr, cast(ubyte)(255 * opacity));
        return zeroOrErrorCode;
    }

    override void destroy() @nogc nothrow
    {
        SDL_DestroyTexture(ptr);
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
            changeOpacity(_opacity);
        }
    }

}
