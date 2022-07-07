module deltotum.display.bitmap.bitmap;

import std.stdio;

import deltotum.display.display_object : DisplayObject;

//TODO extract interfaces
import deltotum.hal.sdl.sdl_texture : SdlTexture;
import deltotum.hal.sdl.sdl_surface : SdlSurface;
import deltotum.hal.sdl.sdl_renderer : SdlRenderer;
import deltotum.hal.sdl.img.sdl_image : SdlImage;
import deltotum.math.rect : Rect;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
//TODO remove duplication with animation bitmap, but it's not clear what code would be required
class Bitmap : DisplayObject
{
    protected
    {
        SdlTexture texture;
    }

    bool load(string path, int requestWidth = -1, int requestHeight = -1)
    {
        import std.path : isAbsolute;
        import std.file : isFile, exists;

        string imagePath = path.isAbsolute ? path : assets.filePath(path);
        if (imagePath.length == 0 || !imagePath.exists || !imagePath.isFile)
        {
            //TODO log, texture placeholder
            return false;
        }

        SdlSurface image = new SdlImage(imagePath);
        int imageWidth = image.width;
        int imageHeight = image.height;

        //TODO move to image
        if (requestWidth > 0 && requestWidth != imageWidth || requestHeight > 0 && requestHeight != imageHeight)
        {
            image.resize(requestWidth, requestHeight);
            imageWidth = image.width;
            imageHeight = image.height;
        }

        texture = new SdlTexture;
        texture.fromRenderer(window.renderer, image);
        int width;
        int height;

        int result = texture.getSize(&width, &height);
        if (result != 0)
        {
            string error = "Unable to load image from " ~ path;
            if (const err = texture.getError)
            {
                error ~= err;
            }
            logger.errorf(error);
            return false;
        }

        this.width = width;
        this.height = height;

        image.destroy;
        requestRedraw;
        return true;
    }

    void drawImage(int x, int y, int width, int height, SDL_RendererFlip flip = SDL_RendererFlip
            .SDL_FLIP_NONE)
    {
        Rect textureBounds = {0, 0, width, height};
        drawTexture(texture, textureBounds, x, y, flip);
    }

    override void drawContent()
    {
        super.drawContent;
        //or double?
        drawImage(cast(int) x, cast(int) y, cast(int) width, cast(int) height);
    }

    override void destroy()
    {
        super.destroy;
        texture.destroy;
    }
}
