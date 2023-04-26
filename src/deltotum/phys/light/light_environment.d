module deltotum.phys.light.light_environment;

import deltotum.kit.display.images.image : Image;
import deltotum.phys.light.light_spot : LightSpot;

//TODO remove hal api
import deltotum.sys.sdl.sdl_texture : SdlTexture;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class LightEnvironment : Image
{
    private
    {
        LightSpot[] lights;
    }

    override void create()
    {
        auto lightTexture = new SdlTexture;
        const createErr = lightTexture.create(graphics.renderer, SDL_PIXELFORMAT_RGBA32,
            SDL_TextureAccess.SDL_TEXTUREACCESS_TARGET, cast(int) window.width,
            cast(int) window.height);
        if(createErr){
            throw new Exception(createErr.toString);
        }
        SDL_SetTextureBlendMode(lightTexture.getObject, SDL_BLENDMODE_MOD);

        this.texture = lightTexture;
        int width, height;
        if(const err = texture.getSize(&width, &height)){
            throw new Exception(err.toString);
        }
        this.width = width;
        this.height = height;

        SDL_SetRenderTarget(graphics.renderer.getObject, texture.getObject);
        //TODO night color?
        if(const err = graphics.renderer.setRenderDrawColor(60, 0, 100, 255)){
            throw new Exception("Error setting render color to create light");
        }
        SDL_RenderFillRect(graphics.renderer.getObject, null);

        foreach (light; lights)
        {
            light.drawImage;
        }

        SDL_SetRenderTarget(graphics.renderer.getObject, null);
    }

    void addLight(LightSpot light)
    {
        //TODO validate
        SDL_SetTextureBlendMode(light.getObject, SDL_BLENDMODE_ADD);
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
