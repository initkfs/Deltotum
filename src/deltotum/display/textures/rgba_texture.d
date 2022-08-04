module deltotum.display.textures.rgba_texture;

import deltotum.display.textures.texture: Texture;

import deltotum.hal.sdl.sdl_texture : SdlTexture;
import deltotum.math.rect : Rect;

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

    override void create()
    {
        super.create;

        texture = new SdlTexture;
        //TODO toInt?
        texture.createRGBA(window.renderer, cast(int) width, cast(int) height);
        texture.setBlendModeBlend;
        window.renderer.setRendererTarget(texture.getStruct);
        createTextureContent;
        window.renderer.resetRendererTarget;
    }
}
