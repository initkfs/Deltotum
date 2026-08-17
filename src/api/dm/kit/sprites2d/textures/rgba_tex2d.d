module api.dm.kit.sprites2d.textures.rgba_tex2d;

import api.dm.kit.sprites2d.textures.tex2d : Tex2d;
import api.dm.kit.graphics.colors.rgba : RGBA;

import api.math.geom2.rect2 : Rect2f;

/**
 * Authors: initkfs
 */
abstract class RgbaTex2d : Tex2d
{
    this(float width = 100, float height = 100)
    {
        super();
        this.width = width;
        this.height = height;

        this.id = "rgba_texture";
    }

    abstract void createContent();

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

        if (const err = texture.setRenderTarget)
        {
            throw new Exception(err.toString);
        }
        onRenderer();
        if (const err = texture.restoreRenderTarget)
        {
            throw new Exception(err.toString);
        }
    }

    override bool recreate()
    {
        if (!texture)
        {
            texture = graphic.comTextureProvider.getNew();
        }

        //autodisposing should work in ComTex
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
                graphic.clear(RGBA.transparent);
            }

            createContent;
        });

        return true;
    }
}
