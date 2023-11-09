module deltotum.kit.sprites.images.image;

import deltotum.kit.sprites.sprite : Sprite;

import deltotum.com.graphics.com_texture : ComTexture;
import deltotum.com.graphics.com_image : ComImage;
import deltotum.com.graphics.com_surface : ComSurface;
import deltotum.kit.sprites.textures.texture : Texture;
import deltotum.math.shapes.rect2d : Rect2d;
import deltotum.kit.graphics.colors.rgba : RGBA;
import deltotum.math.geom.flip : Flip;

/**
 * Authors: initkfs
 */
//TODO remove duplication with animation bitmap, but it's not clear what code would be required
class Image : Texture
{
    RGBA delegate(int x, int y, RGBA color) colorProcessor;

    this()
    {
        super();
    }

    this(double width, double height)
    {
        this.width = width;
        this.height = height;
    }

    this(ComTexture texture)
    {
        super(texture);
    }

    protected bool load(ComSurface image, int requestWidth = -1, int requestHeight = -1)
    {
        assert(image);
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
            if (scale != 1)
            {
                bool isResized;
                //TODO check non negative resize
                if (const err = image.resize(cast(int)(imageWidth * scale), cast(int)(
                        imageHeight * scale), isResized))
                {
                    throw new Exception(err.toString);
                }
                imageWidth = image.width;
                imageHeight = image.height;
            }
        }

        if (colorProcessor)
        {
            if (const err = image.lock)
            {
                throw new Exception(err.toString);
            }

            scope (exit)
            {
                if (const err = image.unlock)
                {
                    throw new Exception(err.toString);
                }
            }

            foreach (y; 0 .. image.height)
            {
                foreach (x; 0 .. image.width)
                {
                    //TODO more optimal iteration
                    uint* pixelPtr = image.getPixel(x, y);
                    ubyte r, g, b, a;
                    image.getPixelRGBA(pixelPtr, r, g, b, a);
                    RGBA oldColor = {r, g, b, RGBA.fromAnorm(a)};
                    RGBA newColor = colorProcessor(x, y, oldColor);
                    if (newColor != oldColor)
                    {
                        image.setPixelRGBA(x, y, newColor.r, newColor.g, newColor.b, newColor.aNorm);
                    }
                }
            }
        }

        if (!texture)
        {
            texture = graphics.newComTexture;
        }

        if (const err = texture.fromSurface(image))
        {
            throw new Exception(err.toString);
        }

        int width;
        int height;

        if (const err = texture.getSize(width, height))
        {
            logger.errorf(err.toString);
            return false;
        }

        this.width = width;
        this.height = height;

        return true;
    }

    bool load(string path, int requestWidth = -1, int requestHeight = -1)
    {
        import std.path : isAbsolute;
        import std.file : isFile, exists;

        assert(isBuilt);

        string imagePath = path.isAbsolute ? path : asset.imagePath(path);
        if (imagePath.length == 0 || !imagePath.exists || !imagePath.isFile)
        {
            logger.error("Unable to load image, empty path or not a file: ", imagePath);
            return false;
        }

        ComImage image = graphics.newComImage;
        if (const err = image.load(path))
        {
            logger.error("Unable to load image: ", err);
            return false;
        }

        ComSurface comSurf;
        if (const err = image.toSurface(comSurf))
        {
            logger.error("Cannot convert image to surface from path ", path);
            return false;
        }
        return load(comSurf, requestWidth, requestHeight);
    }

    bool loadRaw(const(void[]) content, int requestWidth = -1, int requestHeight = -1)
    {
        auto image = graphics.newComImage;
        import std.conv : to;

        if (const err = image.load(content))
        {
            throw new Exception(err.toString);
        }
        ComSurface surf = graphics.newComSurface;
        if (const err = image.toSurface(surf))
        {
            throw new Exception(err.toString);
        }
        return load(surf, requestWidth, requestHeight);
    }

    bool load(RGBA[][] colorBuf)
    {
        assert(width > 0);
        assert(height > 0);
        //TODO check width, height == colorBuf.dims
        createMutRGBA32;
        assert(texture);

        lock;
        scope (exit)
        {
            unlock;
        }

        foreach (yy, ref RGBA[] colors; colorBuf)
        {
            foreach (xx, ref RGBA color; colors)
            {
                uint x = cast(uint) xx;
                uint y = cast(uint) yy;

                RGBA newColor = colorProcessor ? colorProcessor(x, y, color) : color;
                changeColor(x, y, newColor);
            }
        }
        return true;
    }
}
