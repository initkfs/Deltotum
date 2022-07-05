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
    this(SDL_Texture* ptr)
    {
        super(ptr);
    }

    this()
    {
        super();
    }

    int getSize(int* width, int* height)
    {
        const int zeroOrErrorCode = SDL_QueryTexture(ptr, null, null, width, height);
        return zeroOrErrorCode;
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
    }

    override void destroy() @nogc nothrow
    {
        SDL_DestroyTexture(ptr);
    }
}
