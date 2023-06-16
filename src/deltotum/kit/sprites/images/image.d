module deltotum.kit.sprites.images.image;

import std.stdio;

import deltotum.kit.sprites.images.texture_image : TextureImage;

//TODO remove hal api
import deltotum.sys.sdl.sdl_texture: SdlTexture;

/**
 * Authors: initkfs
 */
//TODO remove duplication with animation bitmap, but it's not clear what code would be required
class Image : TextureImage
{
    this()
    {
        super();
    }

    this(SdlTexture texture)
    {
        super(texture);
    }

    this(double width, double height)
    {
        this.width = width;
        this.height = height;
    }

    override void drawContent()
    {
        drawImage;
        super.drawContent;
    }
}
