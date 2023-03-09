module deltotum.toolkit.display.textures.rgba_texture;

import deltotum.toolkit.display.textures.texture : Texture;

import deltotum.platform.sdl.sdl_texture : SdlTexture;
import deltotum.core.maths.shapes.rect2d : Rect2d;

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
        const createErr = texture.createRGBA(window.renderer, cast(int) width, cast(int) height);
        if (createErr)
        {
            throw new Exception(createErr.toString);
        }
        if (const blendErr = texture.setBlendModeBlend)
        {
            throw new Exception(blendErr.toString);
        }
        window.renderer.setRendererTarget(texture.getObject);
        createTextureContent;
        window.renderer.resetRendererTarget;
    }
}
