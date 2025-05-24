module api.dm.kit.sprites2d.textures.rgba_texture;

import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.graphics.colors.rgba : RGBA;

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

        this.id = "rgba_texture";
    }

    abstract void createTextureContent();

    override void create()
    {
        super.create;
        recreate;
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
        if (const err = texture.restoreRendererTarget)
        {
            throw new Exception(err.toString);
        }
    }

    override bool recreate()
    {
        if (!texture)
        {
            texture = graphics.comTextureProvider.getNew();
        }

        //autodisposing should work in ComTexture
        if (const createErr = texture.createTargetRGBA32(cast(int) width, cast(int) height))
        {
            throw new Exception(createErr.toString);
        }

        if (const blendErr = texture.setBlendModeNone)
        {
            throw new Exception(blendErr.toString);
        }

        captureRenderer(() {

            if (_width > 0 && _height > 0)
            {
                graphics.clear(RGBA.transparent);
            }

            createTextureContent;
        });

        return true;
    }
}
