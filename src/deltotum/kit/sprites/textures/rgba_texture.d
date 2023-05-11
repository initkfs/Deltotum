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

        auto newTexture = texture is null ? graphics.newComTexture : texture;
        //TODO toInt?
        const createErr = newTexture.createRGBA(cast(int) width, cast(int) height);
        if (createErr)
        {
            throw new Exception(createErr.toString);
        }
        if (const blendErr = newTexture.setBlendModeBlend)
        {
            throw new Exception(blendErr.toString);
        }

        //TODO move to TextureCanvas
        newTexture.setRendererTarget;
        createTextureContent;
        newTexture.resetRendererTarget;

        if (!texture)
        {
            texture = newTexture;
        }
    }
}
