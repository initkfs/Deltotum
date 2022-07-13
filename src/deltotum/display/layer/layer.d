module deltotum.display.layer.layer;

import deltotum.display.display_object : DisplayObject;
import deltotum.hal.sdl.sdl_texture : SdlTexture;
import deltotum.hal.sdl.sdl_renderer : SdlRenderer;

//TODO remove hal api
import bindbc.sdl;

/**
 * Authors: initkfs
 */
class Layer : DisplayObject
{
    private
    {
        SdlTexture texture;
    }

    this(SdlRenderer renderer, int width, int height)
    {
        texture = new SdlTexture;
        texture.create(renderer, SDL_PIXELFORMAT_RGBA32, SDL_TEXTUREACCESS_TARGET, width, height);
    }

    SDL_Texture* getStruct()
    {
        return texture.getStruct;
    }
}
