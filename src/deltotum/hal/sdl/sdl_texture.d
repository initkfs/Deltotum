module deltotum.hal.sdl.sdl_texture;

import deltotum.hal.sdl.base.sdl_object_wrapper : SdlObjectWrapper;

import bindbc.sdl;

class SdlTexture : SdlObjectWrapper!SDL_Texture
{
    this(SDL_Texture* ptr)
    {
        super(ptr);
    }

    override void destroy() @nogc nothrow
    {
        SDL_DestroyTexture(ptr);
    }
}
