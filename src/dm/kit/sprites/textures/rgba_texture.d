module dm.kit.sprites.textures.rgba_texture;

import dm.kit.sprites.textures.texture : Texture;

import dm.math.rect2d : Rect2d;

/**
 * Authors: initkfs
 */
class RgbaTexture : Texture
{
    this(double width = 100, double height = 100)
    {
        super();
        this.width = width;
        this.height = height;
    }

    void createTextureContent()
    {

    }

    override void create()
    {
        super.create;

        if (!texture)
        {
            texture = graphics.comTextureProvider.getNew();
        }
        
        //autodisposing should work in ComTexture
        if (const createErr = texture.createTargetRGBA32(cast(int) width, cast(int) height))
        {
            throw new Exception(createErr.toString);
        }

        if (const blendErr = texture.setBlendModeBlend)
        {
            throw new Exception(blendErr.toString);
        }

        captureRenderer(() { createTextureContent; });
    }

    void captureRenderer(scope void delegate() onRenderer)
    {
        if (!texture)
        {
            return;
        }

        if (const err = texture.setRendererTarget)
        {
            throw new Exception(err.toString);
        }
        onRenderer();
        if (const err = texture.resetRendererTarget)
        {
            throw new Exception(err.toString);
        }
    }
}
