module api.dm.kit.sprites.sprites2d.textures.rgba_texture;

import api.dm.kit.sprites.sprites2d.textures.texture2d : Texture2d;

import api.math.geom2.rect2 : Rect2d;

/**
 * Authors: initkfs
 */
abstract class RgbaTexture : Texture2d
{
    this(double width = 100, double height = 100)
    {
        super();
        this.width = width;
        this.height = height;
    }

    abstract void createTextureContent();

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
