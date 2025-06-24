module api.dm.kit.sprites2d.images.image;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;

import api.dm.com.graphic.com_texture : ComTexture;
import api.dm.com.graphic.com_image : ComImage;
import api.dm.com.graphic.com_surface : ComSurface;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.math.geom2.rect2 : Rect2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.pos2.flip : Flip;

import Math = api.math;

/**
 * Authors: initkfs
 */
//TODO remove duplication with animation bitmap, but it's not clear what code would be required
class Image : Texture2d
{
    RGBA delegate(int x, int y, RGBA color) colorProcessor;

    bool isInterpolationResize;
    bool isKeepOriginalColorBuffer;
    RGBA[][] originalBuffer;

    double dwidth = 0;
    double dheight = 0;
    double dsizeDelta = 15;

    this()
    {
        super();
    }

    this(double width, double height)
    {
        forceWidth = width;
        forceHeight = height;
    }

    this(ComTexture texture)
    {
        super(texture);
    }

    bool load(ComSurface image, int requestWidth = -1, int requestHeight = -1)
    {
        assert(image);
        int imageWidth;
        int imageHeight;

        if (auto err = image.getWidth(imageWidth))
        {
            throw new Exception(err.toString);
        }

        if (auto err = image.getHeight(imageHeight))
        {
            throw new Exception(err.toString);
        }

        if (requestWidth > 0 && requestWidth != imageWidth || requestHeight > 0 && requestHeight != imageHeight)
        {
            bool isResized;
            if (const err = image.resize(cast(int)(requestWidth * scale), cast(int)(
                    requestHeight * scale), isResized))
            {
                throw new Exception(err.toString);
            }

            if (auto err = image.getWidth(imageWidth))
            {
                throw new Exception(err.toString);
            }

            if (auto err = image.getHeight(imageHeight))
            {
                throw new Exception(err.toString);
            }
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

                if (auto err = image.getWidth(imageWidth))
                {
                    throw new Exception(err.toString);
                }

                if (auto err = image.getHeight(imageHeight))
                {
                    throw new Exception(err.toString);
                }
            }
        }

        //TODO test functionality, remove
        if (isKeepOriginalColorBuffer || isInterpolationResize)
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

            originalBuffer = new RGBA[][](imageHeight, imageWidth);

            foreach (y; 0 .. imageHeight)
            {
                foreach (x; 0 .. imageWidth)
                {
                    uint* pixelPtr;
                    if (const err = image.getPixel(x, y, pixelPtr))
                    {
                        throw new Exception(err.toString);
                    }
                    ubyte r, g, b, a;
                    if (const err = image.getPixelRGBA(pixelPtr, r, g, b, a))
                    {
                        throw new Exception(err.toString);
                    }
                    originalBuffer[y][x] = RGBA(r, g, b, RGBA.fromAByte(a));
                }
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

            foreach (y; 0 .. imageHeight)
            {
                foreach (x; 0 .. imageWidth)
                {
                    //TODO more optimal iteration
                    uint* pixelPtr;
                    if (const err = image.getPixel(x, y, pixelPtr))
                    {
                        throw new Exception(err.toString);
                    }
                    ubyte r, g, b, a;
                    if (const err = image.getPixelRGBA(pixelPtr, r, g, b, a))
                    {
                        throw new Exception(err.toString);
                    }
                    RGBA oldColor = {r, g, b, RGBA.fromAByte(a)};
                    RGBA newColor = colorProcessor(x, y, oldColor);
                    if (newColor != oldColor)
                    {
                        if (const err = image.setPixelRGBA(x, y, newColor.r, newColor.g, newColor.b, newColor
                                .aByte))
                        {
                            throw new Exception(err.toString);
                        }
                    }

                    if (originalBuffer)
                    {
                        originalBuffer[y][x] = newColor;
                    }
                }
            }
        }

        if (!texture)
        {
            texture = graphic.comTextureProvider.getNew();
        }

        if (const err = texture.create(image))
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

        forceWidth = width;
        forceHeight = height;

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

        ComImage image = graphic.comImageProvider.getNew();
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
        if (load(comSurf, requestWidth, requestHeight))
        {
            comSurf.dispose;
            return true;
        }

        logger.error("Error loading image from ", path);
        return false;
    }

    bool loadRaw(const(void[]) content, int requestWidth = -1, int requestHeight = -1)
    {
        auto image = graphic.comImageProvider.getNew();
        import std.conv : to;

        if (const err = image.load(content))
        {
            logger.error("Cannot load image from raw data: ", err);
        }

        ComSurface surf;
        if (const err = image.toSurface(surf))
        {
            logger.error("Cannot convert image to surface from raw data: ", err);
        }

        if (load(surf, requestWidth, requestHeight))
        {
            surf.dispose;
            return true;
        }

        logger.error("Error loading raw image");
        return false;
    }

    bool load(RGBA[][] colorBuf, bool isKeepColorBuffer = false)
    {
        assert(width > 0);
        assert(height > 0);

        //TODO check is mutable
        if (texture)
        {
            texture.dispose;
            texture = null;
        }

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

        if (isKeepColorBuffer)
        {
            originalBuffer = colorBuf;
        }

        return true;
    }

    void savePNG(ComSurface surf, string path)
    {
        auto image = graphic.comImageProvider.getNew();
        if (const err = image.savePNG(surf, path))
        {
            throw new Exception(err.toString);
        }
    }

    alias width = Texture2d.width;
    alias height = Texture2d.height;

    override bool width(double v)
    {
        if (!canChangeWidth(v))
        {
            return false;
        }

        if (width == 0 || height == 0)
        {
            return super.width(v);
        }

        import std.conv : to;

        double dw = Math.abs(width - v);
        dwidth += dw;

        bool isResized = tryWidth(v);
        assert(isResized);

        if (isInterpolationResize && originalBuffer && originalBuffer.length > 0)
        {
            if (dwidth >= dsizeDelta)
            {
                import ColorProcessor = api.dm.kit.graphics.colors.processing.color_processor;

                auto biBuff = ColorProcessor.resizeBilinear(originalBuffer, width.to!size_t, height
                        .to!size_t);
                load(biBuff);

                dwidth = 0;
            }

        }

        return isResized;
    }

    override bool height(double v)
    {
        if (!canChangeHeight(v))
        {
            return false;
        }

        if (width == 0 || height == 0)
        {
            return super.height(v);
        }

        import std.conv : to;

        double dh = Math.abs(height - v);
        dheight += dh;

        bool isResized = tryHeight(v);
        assert(isResized);

        if (isInterpolationResize && originalBuffer && originalBuffer.length > 0)
        {
            if (dheight >= dsizeDelta)
            {
                import ColorProcessor = api.dm.kit.graphics.colors.processing.color_processor;

                auto biBuff = ColorProcessor.resizeBilinear(originalBuffer, width.to!size_t, height
                        .to!size_t);
                load(biBuff);
                dheight = 0;
            }

        }

        return isResized;
    }
}
