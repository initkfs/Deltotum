module deltotum.display.textures.texture;

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
