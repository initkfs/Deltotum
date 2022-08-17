module deltotum.display.images.image;

import std.stdio;

import deltotum.display.images.loadable_image : LoadableImage;

//TODO remove hal api
import deltotum.hal.sdl.sdl_texture: SdlTexture;

/**
 * Authors: initkfs
 */
//TODO remove duplication with animation bitmap, but it's not clear what code would be required
class Image : LoadableImage
{
    this()
    {
        super();
    }

    this(SdlTexture texture)
    {
        super(texture);
    }

    override void drawContent()
    {
        super.drawContent;
        drawImage;
    }
}
