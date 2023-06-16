module deltotum.kit.sprites.images.texture_image;

import deltotum.kit.sprites.sprite : Sprite;

//TODO extract interfaces
import deltotum.sys.sdl.sdl_texture : SdlTexture;
import deltotum.sys.sdl.sdl_surface : SdlSurface;
import deltotum.sys.sdl.sdl_renderer : SdlRenderer;
import deltotum.sys.sdl.img.sdl_image : SdlImage;
import deltotum.kit.sprites.textures.texture : Texture;
import deltotum.math.shapes.rect2d : Rect2d;
import deltotum.kit.graphics.colors.rgba : RGBA;
import deltotum.kit.sprites.flip : Flip;
import deltotum.kit.sprites.images.bitmaps.bitmap : Bitmap;

import bindbc.sdl;

//TODO struct? 
import bindbc.sdl;

struct Pixel
{
    uint* ptr;
    int x, y;
    SDL_PixelFormat* format;

    void setColor(RGBA color)
    {
        const newColor = SDL_MapRGBA(format, color.r, color.g, color.b, color.aNorm);
        *ptr = newColor;
    }

    RGBA getColor()
    {
        ubyte r, g, b, a;
        SDL_GetRGBA(*ptr, format, &r, &g, &b, &a);
        return RGBA(r, g, b, a / ubyte.max);
    }
}

/**
 * Authors: initkfs
 */
//TODO remove duplication with animation bitmap, but it's not clear what code would be required
class TextureImage : Texture
{
    void delegate(Pixel) colorProcessor;

    this()
    {
        super();
    }

    this(SdlTexture texture)
    {
        super(texture);
    }

    bool createMutableRGBA32()
    {
        assert(width > 0 && height > 0);

        texture = graphics.newComTexture;

        if (const err = texture.createMutableRGBA32(cast(int) width, cast(int) height))
        {
            //TODO log
            throw new Exception(err.toString);
        }

        return true;
    }

    bool load(Bitmap bitmap)
    {
        import deltotum.sys.sdl.sdl_surface : SdlSurface;

        auto surface = new SdlSurface;
        //TODO alpha mask?
        if (const err = surface.createRGBSurfaceFrom(bitmap.bits, bitmap.width, bitmap.height, bitmap.bpp, bitmap
                .pitch, bitmap.redMask, bitmap.greenMask, bitmap.blueMask, 0))
        {
            throw new Exception(err.toString);
        }

        texture = graphics.newComTexture;
        if (const err = texture.fromSurface(surface))
        {
            throw new Exception(err.toString);
        }
        int width;
        int height;

        if (const err = texture.getSize(&width, &height))
        {
            logger.errorf(err.toString);
            return false;
        }

        this.width = width * scale;
        this.height = height * scale;

        surface.destroy;
        return true;
    }

    bool loadRaw(string content, int requestWidth = -1, int requestHeight = -1)
    {
        //TODO remove bindbc
        import bindbc.sdl;
        import std.string : toStringz;

        SDL_RWops* rw = SDL_RWFromConstMem(cast(const(void*)) content.toStringz, cast(int) content
                .length);
        if (!rw)
        {
            throw new Exception("Cannot create memory buffer");
        }
        // scope (exit)
        // {
        //     SDL_RWclose(rw);
        // }

        SDL_Surface* surface = IMG_Load_RW(rw, 1);
        if (!surface)
        {
            throw new Exception("Image loading error");
        }

        SdlSurface surf = new SdlSurface(surface);
        if (colorProcessor)
        {
            if (const err = surf.lock)
            {
                throw new Exception(err.toString);
            }

            scope (exit)
            {
                if (const err = surf.unlock)
                {
                    throw new Exception(err.toString);
                }
            }

            foreach (y; 0 .. surf.height)
            {
                foreach (x; 0 .. surf.width)
                {
                    //TODO more optimal iteration
                    uint* pixel = surf.pixel(x, y);
                    auto pixelPtr = Pixel(pixel, x, y, surf.getObject.format);
                    colorProcessor(pixelPtr);
                }
            }
        }

        return load(surf, requestWidth, requestHeight);
    }

    bool load(RGBA[][] colorBuf)
    {
        assert(width > 0);
        assert(height > 0);
        //TODO check width, height == colorBuf.dims
        createMutableRGBA32;
        assert(texture);

        uint* pixels;
        int pitch;
        lock(pixels, pitch);
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

                changeColor(x, y, pixels, pitch, color);

                if(colorProcessor){
                    //TODO multiple request
                    SDL_PixelFormat* format;
                    if (const err = texture.getFormat(format))
                    {
                        throw new Exception(err.toString);
                    }
                    uint* pixelPtr;
                    pixel(x, y, pixels, pitch, pixelPtr);
                    //TODO caches
                    colorProcessor(Pixel(pixelPtr, x, y, format));
                }    
                

            }
        }
        return true;
    }

    protected bool load(SdlSurface image, int requestWidth = -1, int requestHeight = -1)
    {
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
                if (const err = image.resize(cast(int)(imageWidth * scale), cast(int)(
                        imageHeight * scale), isResized))
                {
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

        texture = graphics.newComTexture;
        if (const err = texture.fromSurface(image))
        {
            throw new Exception(err.toString);
        }
        int width;
        int height;

        int result = texture.getSize(&width, &height);
        if (result != 0)
        {
            string error = "Unable to load image.";
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

        return true;
    }

    bool load(string path, int requestWidth = -1, int requestHeight = -1)
    {
        import std.path : isAbsolute;
        import std.file : isFile, exists;

        string imagePath = path.isAbsolute ? path : asset.image(path);
        if (imagePath.length == 0 || !imagePath.exists || !imagePath.isFile)
        {
            //TODO log, texture placeholder
            return false;
        }

        SdlSurface image = new SdlImage(imagePath);
        return load(image, requestWidth, requestHeight);
    }

    bool createMutable(out ubyte* data)
    {
        if (width <= 0 || height <= 0)
        {
            logger.error("Unable to create an image with zero dimensions");
            return false;
        }

        if (const err = texture.createMutableRGBA32(cast(int) width, cast(int) height))
        {
            logger.errorf("Error creating mutable texture for image, width %s, height %s. %s", width, height, err
                    .toString);
            return false;
        }

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
