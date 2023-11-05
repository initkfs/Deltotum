module deltotum.kit.sprites.textures.rgba_texture;

import deltotum.kit.sprites.textures.texture : Texture;

import deltotum.sys.sdl.sdl_texture : SdlTexture;
import deltotum.math.shapes.rect2d : Rect2d;

/**
 * Authors: initkfs
 */
class RgbaTexture : Texture
{
    this(double width, double height)
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
            texture = graphics.newComTexture;
        }

        recreate;

    }

    override void recreate()
    {
        //TODO toInt?
        const createErr = texture.createTargetRGBA32(cast(int) width, cast(int) height);
        if (createErr)
        {
            throw new Exception(createErr.toString);
        }
        if (const blendErr = texture.setModeBlend)
        {
            throw new Exception(blendErr.toString);
        }

        //TODO move to TextureCanvas
        captureRenderer(() { createTextureContent; });
    }

    void captureRenderer(scope void delegate() onRenderer)
    {
        if (!texture)
        {
            return;
        }

        if(const err = texture.setRendererTarget){
            throw new Exception(err.toString);
        }
        onRenderer();
        if(const err = texture.resetRendererTarget){
            throw new Exception(err.toString);
        }
    }
}
