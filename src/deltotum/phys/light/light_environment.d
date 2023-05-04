module deltotum.phys.light.light_environment;

import deltotum.kit.sprites.images.image : Image;
import deltotum.phys.light.light_spot : LightSpot;

//TODO remove hal api
import deltotum.sys.sdl.sdl_texture : SdlTexture;
import deltotum.kit.graphics.colors.rgba : RGBA;

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
        auto lightTexture = graphics.newComTexture;
        const createErr = lightTexture.create(SDL_PIXELFORMAT_RGBA32,
            SDL_TextureAccess.SDL_TEXTUREACCESS_TARGET, cast(int) window.width,
            cast(int) window.height);
        if (createErr)
        {
            throw new Exception(createErr.toString);
        }
        SDL_SetTextureBlendMode(lightTexture.getObject, SDL_BLENDMODE_MOD);

        this.texture = lightTexture;
        int width, height;
        if (const err = texture.getSize(&width, &height))
        {
            throw new Exception(err.toString);
        }
        this.width = width;
        this.height = height;

        texture.setRendererTarget;
        //TODO night color?
        graphics.setColor(RGBA(60, 0, 100, 255));
        //SDL_RenderFillRect(graphics.renderer.getObject, null);

        foreach (light; lights)
        {
            light.drawImage;
        }

        texture.resetRendererTarget;
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
