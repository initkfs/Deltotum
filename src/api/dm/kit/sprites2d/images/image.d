module api.dm.kit.sprites2d.images.image;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;

import api.dm.com.graphics.com_texture : ComTexture;
import api.dm.com.graphics.com_image_codec : ComImageCodec;
import api.dm.com.graphics.com_surface : ComSurface;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.math.geom2.rect2 : Rect2f;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.pos2.flip : Flip;

import Math = api.math;

/**
 * Authors: initkfs
 */
//TODO remove duplication with animation bitmap, but it's not clear what code would be required
class Image : Texture2d
{
    RGBA delegate(int x, int y, RGBA color) onColor;

    bool isInterpolationResize;
    bool isKeepOriginalColorBuffer;
    RGBA[][] originalBuffer;

    float dwidth = 0;
    float dheight = 0;
    float dsizeDelta = 15;

    bool isKeepSurface;
    ComSurface surface;

    this()
    {
        super();
    }

    this(float width, float height)
    {
        forceWidth = width;
        forceHeight = height;
    }

    this(ComTexture texture)
    {
        super(texture);
    }

    void load(ComSurface image, int requestWidth = -1, int requestHeight = -1)
    {
        assert(image);
        int imageWidth = image.getWidth;
        int imageHeight = image.getHeight;

        if (requestWidth > 0 && requestWidth != imageWidth || requestHeight > 0 && requestHeight != imageHeight)
        {
            bool isResized;
            if (const err = image.resize(cast(int)(requestWidth * scale), cast(int)(
                    requestHeight * scale), isResized))
            {
                throw new Exception(err.toString);
            }

            imageWidth = image.getWidth;
            imageHeight = image.getHeight;
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

                imageWidth = image.getWidth;
                imageHeight = image.getHeight;
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

        if (onColor)
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
                    RGBA newColor = onColor(x, y, oldColor);
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
            throw new Exception(err.toString);
        }

        forceWidth = width;
        forceHeight = height;

        if (isKeepSurface)
        {
            if (surface)
            {
                surface.dispose;
            }
            else
            {
                this.surface = graphic.comSurfaceProvider.getNew();
            }

            if (const err = image.copyTo(surface))
            {
                throw new Exception(err.toString);
            }
        }
    }

    void load(string path, int requestWidth = -1, int requestHeight = -1)
    {
        import std.path : isAbsolute;
        import std.file : isFile, exists;

        assert(isBuilt);

        string imagePath = path.isAbsolute ? path : asset.imagePath(path);
        if (imagePath.length == 0 || !imagePath.exists || !imagePath.isFile)
        {
            throw new Exception("Unable to load image, empty path or not a file: " ~ imagePath);
        }

        ComSurface comSurf;

        foreach (codec; graphic.comImageCodecs)
        {
            if (codec.isSupport(path))
            {
                comSurf = graphic.comSurfaceProvider.getNew();
                if (const err = codec.load(path, comSurf))
                {
                    throw new Exception(err.toString);
                }
                break;
            }
        }

        if (!comSurf)
        {
            throw new Exception("Image not loaded: ", path);
        }

        scope (exit)
        {
            comSurf.dispose;
        }

        load(comSurf, requestWidth, requestHeight);
    }

    void loadRaw(const(ubyte[]) buff, int requestWidth = -1, int requestHeight = -1)
    {
        //TODO remove duplication with load
        ComSurface comSurf;

        foreach (codec; graphic.comImageCodecs)
        {
            if (codec.isSupport(buff))
            {
                comSurf = graphic.comSurfaceProvider.getNew();
                if (const err = codec.load(buff, comSurf))
                {
                    throw new Exception(err.toString);
                }
                break;
            }
        }

        if (!comSurf)
        {
            throw new Exception("Image not loaded from memory buffer");
        }

        scope (exit)
        {
            comSurf.dispose;
        }

        load(comSurf, requestWidth, requestHeight);
    }

    void load(RGBA[][] colorBuf, bool isKeepColorBuffer = false)
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

                RGBA newColor = onColor ? onColor(x, y, color) : color;
                changeColor(x, y, newColor);
            }
        }

        if (isKeepColorBuffer)
        {
            originalBuffer = colorBuf;
        }
    }

    void save(ComSurface surf, string path)
    {
        bool isSave;

        foreach (codec; graphic.comImageCodecs)
        {
            if (codec.isSupport(path))
            {
                if (const err = codec.save(path, surf))
                {
                    throw new Exception(err.toString);
                }
                isSave = true;
                break;
            }
        }

        if (!isSave)
        {
            throw new Exception("Image not saved: ", path);
        }
    }

    void save(string path)
    {
        //TODO texture must be streaming
        // graphic.comSurfaceProvider.getNewScoped((surface) {
        //     if (const err = texture.lockToSurface(surface))
        //     {
        //         throw new Exception(err.toString);
        //     }

        //     save(surface, path);
        // });

        if (!surface)
        {
            throw new Exception("Surface is null");
        }

        save(surface, path);
    }

    alias width = Texture2d.width;
    alias height = Texture2d.height;

    override bool width(float v)
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

        float dw = Math.abs(width - v);
        dwidth += dw;

        bool isResized = tryWidth(v);
        assert(isResized);

        if (isInterpolationResize && originalBuffer && originalBuffer.length > 0)
        {
            if (dwidth >= dsizeDelta)
            {
                import Transform = api.dm.kit.graphics.colors.processings.transforms;

                auto biBuff = Transform.bilinear(originalBuffer, width.to!size_t, height
                        .to!size_t);
                load(biBuff);

                dwidth = 0;
            }

        }

        return isResized;
    }

    override bool height(float v)
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

        float dh = Math.abs(height - v);
        dheight += dh;

        bool isResized = tryHeight(v);
        assert(isResized);

        if (isInterpolationResize && originalBuffer && originalBuffer.length > 0)
        {
            if (dheight >= dsizeDelta)
            {
                import Transform = api.dm.kit.graphics.colors.processings.transforms;

                auto biBuff = Transform.bilinear(originalBuffer, width.to!size_t, height
                        .to!size_t);
                load(biBuff);
                dheight = 0;
            }

        }

        return isResized;
    }
}
