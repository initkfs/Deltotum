module deltotum.display.layer.light_layer;

import deltotum.hal.sdl.sdl_texture : SdlTexture;
import deltotum.hal.sdl.sdl_renderer : SdlRenderer;
import deltotum.display.light.light_spot : LightSpot;
import deltotum.display.layer.layer : Layer;

//TODO remove hal api
import bindbc.sdl;

/**
 * Authors: initkfs
 */
class LightLayer : Layer
{
    private
    {
        @property LightSpot[] lights = [];
    }

    this(SdlRenderer renderer, int width, int height)
    {
        super(renderer, width, height);
        SDL_SetTextureBlendMode(getStruct, SDL_BLENDMODE_MOD);
    }

    void addLight(LightSpot light)
    {
        SDL_SetTextureBlendMode(light.getStruct, SDL_BLENDMODE_ADD);
        lights ~= light;
    }

    override void drawContent()
    {
        auto renderer = window.renderer;
        renderer.setRenderDrawColor(60, 0, 100, 255);
        SDL_RenderFillRect(renderer.getStruct, null);

        foreach (LightSpot light; lights)
        {
            SDL_Rect src = {0, 0, cast(int) light.width, cast(int) light.height};
            SDL_Rect dest = {
                cast(int) light.x, cast(int) light.y, cast(int) light.width, cast(int) light.height
            };

            SDL_RenderCopy(renderer.getStruct, light.getStruct, &src, &dest);
        }
    }

}
