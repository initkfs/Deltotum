module deltotum.display.light.light_environment;

import deltotum.display.bitmap.bitmap : Bitmap;
import deltotum.display.light.light_spot : LightSpot;

//TODO remove hal api
import deltotum.hal.sdl.sdl_texture : SdlTexture;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class LightEnvironment : Bitmap
{
    private
    {
        LightSpot[] lights = [];
    }

    override void create()
    {
        auto lightTexture = new SdlTexture;
        lightTexture.create(window.renderer, SDL_PIXELFORMAT_RGBA32,
            SDL_TextureAccess.SDL_TEXTUREACCESS_TARGET, cast(int) window.getWidth,
            cast(int) window.getHeight);
        SDL_SetTextureBlendMode(lightTexture.getStruct, SDL_BLENDMODE_MOD);

        this.texture = lightTexture;
        int width, height;
        texture.getSize(&width, &height);
        this.width = width;
        this.height = height;

        SDL_SetRenderTarget(window.renderer.getStruct, texture.getStruct);
        //TODO night color?
        window.renderer.setRenderDrawColor(60, 0, 100, 255);
        SDL_RenderFillRect(window.renderer.getStruct, null);

        foreach (light; lights)
        {
            light.drawImage;
        }

        SDL_SetRenderTarget(window.renderer.getStruct, null);
    }

    void addLight(LightSpot light)
    {
        //TODO validate
        SDL_SetTextureBlendMode(light.getStruct, SDL_BLENDMODE_ADD);
        lights ~= light;
    }

    override void destroy()
    {
        super.destroy;
        foreach (LightSpot light; lights)
        {
            light.destroy;
        }
        lights = [];
    }

}
