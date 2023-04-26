module deltotum.kit.display.textures.rgba_texture;

import deltotum.kit.display.textures.texture : Texture;

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

        texture = new SdlTexture;
        //TODO toInt?
        const createErr = texture.createRGBA(graphics.renderer, cast(int) width, cast(int) height);
        if (createErr)
        {
            throw new Exception(createErr.toString);
        }
        if (const blendErr = texture.setBlendModeBlend)
        {
            throw new Exception(blendErr.toString);
        }
        graphics.renderer.setRendererTarget(texture.getObject);
        createTextureContent;
        graphics.renderer.resetRendererTarget;
    }
}
