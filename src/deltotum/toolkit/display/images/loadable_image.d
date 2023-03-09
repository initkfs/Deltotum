module deltotum.toolkit.display.images.loadable_image;

import deltotum.toolkit.display.display_object : DisplayObject;

//TODO extract interfaces
import deltotum.platforms.sdl.sdl_texture : SdlTexture;
import deltotum.platforms.sdl.sdl_surface : SdlSurface;
import deltotum.platforms.sdl.sdl_renderer : SdlRenderer;
import deltotum.platforms.sdl.img.sdl_image : SdlImage;
import deltotum.toolkit.display.textures.texture : Texture;
import deltotum.core.maths.shapes.rect2d : Rect2d;
import deltotum.toolkit.display.flip : Flip;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
//TODO remove duplication with animation bitmap, but it's not clear what code would be required
class LoadableImage : Texture
{
    this()
    {
        super();
    }

    this(SdlTexture texture)
    {
        super(texture);
    }

    bool load(string path, int requestWidth = -1, int requestHeight = -1)
    {
        import std.path : isAbsolute;
        import std.file : isFile, exists;

        string imagePath = path.isAbsolute ? path : assets.image(path);
        if (imagePath.length == 0 || !imagePath.exists || !imagePath.isFile)
        {
            //TODO log, texture placeholder
            return false;
        }

        SdlSurface image = new SdlImage(imagePath);
        int imageWidth = image.width;
        int imageHeight = image.height;

        if (requestWidth > 0 && requestWidth != imageWidth || requestHeight > 0 && requestHeight != imageHeight)
        {
            bool isResized;
            if (const err = image.resize(cast(int)(requestWidth * scale), cast(int)(
                    requestHeight * scale), isResized))
            {
                throw new Exception(err.toString);
            }
            imageWidth = image.width;
            imageHeight = image.height;
        }
        else
        {
            if (scale != 1 && scale > 0)
            {
                bool isResized;
                if(const err = image.resize(cast(int)(imageWidth * scale), cast(int)(imageHeight * scale), isResized)){
                    throw new Exception(err.toString);
                }
                imageWidth = image.width;
                imageHeight = image.height;
            }
        }

        if (texture !is null)
        {
            destroy;
        }

        texture = new SdlTexture;
        if (const err = texture.fromRenderer(window.renderer, image))
        {
            throw new Exception(err.toString);
        }
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

        this.width = width * scale;
        this.height = height * scale;

        image.destroy;
        requestRedraw;
        return true;
    }

    void drawImage(Flip flip = Flip.none)
    {
        drawImage(cast(int) x, cast(int) y, cast(int) width, cast(int) height, flip);
    }

    void drawImage(int x, int y, int width, int height, Flip flip = Flip.none)
    {
        if (texture is null)
        {
            //TODO logging
            return;
        }
        Rect2d textureBounds = {0, 0, width, height};
        drawTexture(texture, textureBounds, x, y, angle, flip);
    }

    override void destroy()
    {
        super.destroy;
        if (texture !is null)
        {
            texture.destroy;
        }
    }

    //TODO remove
    SDL_Texture* getObject()
    {
        return texture.getObject;
    }
}
