module deltotum.display.texture.texture;

import deltotum.display.display_object : DisplayObject;

import deltotum.hal.sdl.sdl_texture : SdlTexture;
import deltotum.math.rect : Rect;

/**
 * Authors: initkfs
 */
class Texture : DisplayObject
{
    protected
    {
        SdlTexture texture;
    }

    this(double width, double height)
    {
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

    void createTextureContent(){

    }

    override void drawContent()
    {
        Rect textureBounds = Rect(0, 0, width, height);
        //TODO flip, toInt?
        drawTexture(texture, textureBounds, cast(int) x, cast(int) y, angle);
    }

    override void destroy()
    {
        super.destroy;
        texture.destroy;
    }
}
