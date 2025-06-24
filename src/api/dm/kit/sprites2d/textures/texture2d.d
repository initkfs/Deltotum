module api.dm.kit.sprites2d.textures.texture2d;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;

import api.dm.com.graphic.com_texture : ComTexture;
import api.dm.com.graphic.com_surface : ComSurface;
import api.dm.com.graphic.com_blend_mode : ComBlendMode;
import api.dm.com.graphic.com_texture : ComTextureScaleMode;
import api.math.geom2.rect2 : Rect2d;
import api.math.pos2.flip : Flip;
import api.dm.kit.graphics.colors.rgba : RGBA;

/**
 * Authors: initkfs
 */
class Texture2d : Sprite2d
{
    bool isDrawTexture = true;
    Flip flip = Flip.none;

    protected
    {
        ComTexture texture;
    }

    private
    {
        //hack to reduce memory leak
        double oldChangedWidth = 0;
        double oldChangedHeight = 0;
        double changeSizeDelta = 5;
    }

    void delegate(double, double) onPreRecreateWidthOldNew;
    void delegate(double, double) onPreRecreateHeightOldNew;

    this()
    {
        isResizable = true;
        //isResizedByParent = true;
    }

    this(double width, double height)
    {
        this();
        this.width = width;
        this.height = height;
    }

    this(ComTexture texture)
    {
        assert(texture);

        this();

        int w, h;
        if (const sizeErr = texture.getSize(w, h))
        {
            throw new Exception(sizeErr.toString);
        }

        this.width = w;
        this.height = h;

        this.texture = texture;
    }

    override void create()
    {
        super.create;
        if (texture)
        {
            texture.setNotEmptyId(id);
        }
    }

    void loadFromSurface(ComSurface surface)
    {
        auto newTexture = texture;
        if (!newTexture)
        {
            newTexture = graphic.comTextureProvider.getNew();
        }

        if (const err = newTexture.create(surface))
        {
            throw new Exception(err.toString);
        }
        int w, h;
        if (const sizeErr = newTexture.getSize(w, h))
        {
            throw new Exception(sizeErr.toString);
        }

        this.width = w;
        this.height = h;

        this.texture = newTexture;
    }

    void createMutRGBA32()
    {
        assert(width > 0);
        assert(height > 0);

        texture = graphic.comTextureProvider.getNew();
        if (const err = texture.createMutRGBA32(cast(int) width, cast(int) height))
        {
            throw new Exception(err.toString);
        }
    }

    void createTargetRGBA32()
    {
        assert(width > 0);
        assert(height > 0);
        assert(graphic);

        texture = graphic.comTextureProvider.getNew();
        if (const err = texture.createTargetRGBA32(cast(int) width, cast(int) height))
        {
            throw new Exception(err.toString);
        }
    }

    void createMutYV()
    {
        assert(width > 0);
        assert(height > 0);
        assert(graphic);

        texture = graphic.comTextureProvider.getNew();
        if (const err = texture.createMutYV(cast(int) width, cast(int) height))
        {
            throw new Exception(err.toString);
        }
    }

    void blendMode(ComBlendMode mode)
    {
        if (const err = texture.setBlendMode(mode))
        {
            throw new Exception(err.toString);
        }
    }

    void blendModeBlend()
    {
        blendMode(ComBlendMode.blend);
    }

    void blendModeNone()
    {
        blendMode(ComBlendMode.none);
    }

    ComTextureScaleMode textureScaleMode()
    {
        assert(texture);
        ComTextureScaleMode mode;
        if (const err = texture.getScaleMode(mode))
        {
            logger.error(err.toString);
        }
        return mode;
    }

    void textureScaleMode(ComTextureScaleMode mode)
    {
        assert(texture);
        if (const err = texture.setScaleMode(mode))
        {
            logger.error(err.toString);
        }
    }

    void bestScaleMode()
    {
        textureScaleMode(ComTextureScaleMode.quality);
    }

    override void drawContent()
    {
        if (texture is null)
        {
            return;
        }

        if (isDrawTexture)
        {
            drawTexture;
        }

        super.drawContent;
    }

    void drawTexture()
    {
        Rect2d textureBounds = {0, 0, width, height};
        //TODO flip, toInt?
        Rect2d destBounds = {x, y, width, height};
        drawTexture(texture, textureBounds, destBounds, angle, flip);
    }

    void drawTexture(Rect2d src)
    {
        Rect2d dest = {x, y, src.width, src.height};
        drawTexture(src, dest, this.angle, this.flip);
    }

    void drawTexture(Rect2d textureBounds, Rect2d destBounds)
    {
        drawTexture(textureBounds, destBounds, this.angle, this.flip);
    }

    void drawTexture(Rect2d textureBounds, Rect2d destBounds, double angle = 0, Flip flip = Flip
            .none)
    {
        drawTexture(texture, textureBounds, destBounds, angle, flip);
    }

    void drawTexture(ComTexture texture, Rect2d textureBounds, Rect2d destBounds, double angle = 0, Flip flip = Flip
            .none)
    {
        if (const err = texture.draw(textureBounds, destBounds, angle, flip))
        {
            logger.error(err.toString);
        }
    }

    void color(RGBA color)
    {
        import std.exception : enforce;

        enforce(texture, "Texture2d not created");
        if (const err = texture.setColor(color.r, color.g, color.b, color.aByte))
        {
            throw new Exception(err.toString);
        }
    }

    RGBA color()
    {
        import std.exception : enforce;

        enforce(texture, "Texture2d not created");
        ubyte r, g, b, a;
        if (const err = texture.getColor(r, g, b, a))
        {
            throw new Exception(err.toString);
        }
        return RGBA(r, g, b, a / (cast(double) ubyte.max));
    }

    override double width()
    {
        return super.width;
    }

    override bool width(double value)
    {
        auto isResized = super.width(value);
        if (!isResizable)
        {
            return isResized;
        }
        import Math = api.dm.math;

        if (texture)
        {
            bool isTextureCreated;
            if (const err = texture.isCreated(isTextureCreated))
            {
                logger.error(err.toString);
            }

            if (isTextureCreated && Math.abs(oldChangedWidth - value) > changeSizeDelta)
            {
                if (!isDisableRecreate)
                {
                    if (onPreRecreateWidthOldNew)
                    {
                        onPreRecreateWidthOldNew(oldChangedWidth, width);
                    }
                    recreate;
                }

                oldChangedWidth = width;

                return true;
            }
        }

        return isResized;
    }

    override double height()
    {
        return super.height;
    }

    override bool height(double value)
    {
        auto isResized = super.height(value);
        if (!isResizable)
        {
            return isResized;
        }
        import Math = api.dm.math;

        if (texture)
        {
            bool isTextureCreated;
            if (const err = texture.isCreated(isTextureCreated))
            {
                logger.error(err.toString);
            }

            if (isTextureCreated && Math.abs(oldChangedHeight - value) > changeSizeDelta)
            {
                if (!isDisableRecreate)
                {
                    if (onPreRecreateHeightOldNew)
                    {
                        onPreRecreateHeightOldNew(oldChangedHeight, value);
                    }
                    recreate;
                }
                oldChangedHeight = value;
                return true;
            }
        }

        return isResized;
    }

    override bool recreate()
    {
        return false;
    }

    Texture2d copy()
    {
        assert(texture);
        ComTexture newTexture;
        if (const err = texture.copyToNew(newTexture))
        {
            throw new Exception(err.toString);
        }
        auto toTexture = new Texture2d(newTexture);
        build(toTexture);
        toTexture.initialize;
        toTexture.create;
        return toTexture;
    }

    Texture2d copyTo(double toWidth, double toHeight, bool isToCenter = false)
    {
        auto newTexture = new Texture2d(toWidth, toHeight);
        buildInitCreate(newTexture);

        newTexture.createTargetRGBA32;
        newTexture.setRendererTarget;
        scope (exit)
        {
            newTexture.restoreRendererTarget;
        }
        graphic.clearTransparent;

        copyTo(newTexture, isToCenter);
        return newTexture;
    }

    void copyTo(Texture2d other, bool isToCenter = false)
    {
        other.copyFrom(this, isToCenter);
    }

    void copyFrom(Texture2d other, bool isToCenter = false)
    {
        //TODO check bounds;
        Rect2d srcRect = {0, 0, other.width, other.height};
        Rect2d destRect = !isToCenter ? Rect2d(0, 0, other.width, other.height) : Rect2d(width / 2 - other.width / 2, height / 2 - other
                .height / 2, other.width, other.height);

        copyFrom(other, srcRect, destRect);
    }

    void copyFrom(Texture2d other, Rect2d srcRect, Rect2d dstRect)
    {
        assert(texture);
        if (const err = texture.copyFrom(other.nativeTexture, srcRect, dstRect, other.angle, other
                .flip))
        {
            throw new Exception(err.toString);
        }
    }

    inout(ComTexture) nativeTexture() inout nothrow
    {
        return this.texture;
    }

    bool isLocked()
    {
        assert(texture);
        bool locked;
        if (const err = texture.isLocked(locked))
        {
            throw new Exception(err.toString);
        }
        return locked;
    }

    void lock()
    {
        if (const err = texture.lock)
        {
            throw new Exception(err.toString);
        }
    }

    void changeColor(uint x, uint y, RGBA color)
    {
        if (const err = texture.setPixelColor(x, y, color.r, color.g, color.b, color.aByte))
        {
            throw new Exception(err.toString);
        }
    }

    uint format()
    {
        assert(texture);
        assert(isLocked);
        uint format;
        if (const err = texture.getFormat(format))
        {
            throw new Exception(err.toString);
        }
        return format;
    }

    int pitch()
    {
        assert(texture);
        assert(isLocked);
        int pitch;
        if (const err = texture.getPixelRowLenBytes(pitch))
        {
            throw new Exception(err.toString);
        }
        return pitch;
    }

    void* pixels()
    {
        assert(texture);
        assert(isLocked);
        void* ptr;
        if (const err = texture.getPixels(ptr))
        {
            throw new Exception(err.toString);
        }
        assert(ptr);
        return ptr;
    }

    uint* pixel(uint x, uint y)
    {
        assert(texture);
        assert(isLocked);
        uint* ptr;
        if (const err = texture.getPixel(x, y, ptr))
        {
            throw new Exception(err.toString);
        }
        return ptr;
    }

    RGBA[][] pixelColors()
    {
        assert(width > 0);
        assert(height > 0);
        RGBA[][] buff = new RGBA[][](cast(size_t) height, cast(size_t) width);
        pixelColors(buff);
        return buff;
    }

    void pixelColors(RGBA[][] buff)
    {
        assert(width > 0);
        assert(height > 0);
        assert(texture);
        assert(isLocked);
        assert(buff.length >= height);

        //TODO all rows
        assert(buff[0].length >= width);

        foreach (y; 0 .. (cast(uint) height))
        {
            foreach (x; 0 .. (cast(uint)(width)))
            {
                buff[y][x] = pixelColor(x, y);
            }
        }
    }

    void setPixelColors(RGBA[][] buff)
    {
        //TODO width > 0, etc
        //TODO check buffer size
        foreach (y; 0 .. (cast(uint) height))
        {
            foreach (x; 0 .. (cast(uint)(width)))
            {
                auto color = buff[y][x];
                changeColor(x, y, color);
            }
        }
    }

    RGBA pixelColor(double x, double y)
    {
        import std.conv : to;

        return pixelColor(x.to!uint, y.to!uint);
    }

    RGBA pixelColor(uint x, uint y)
    {
        assert(texture);
        assert(isLocked);
        ubyte r, g, b, a;
        if (const err = texture.getPixelColor(x, y, r, g, b, a))
        {
            throw new Exception(err.toString);
        }
        return RGBA(r, g, b, RGBA.fromAByte(a));
    }

    void unlock()
    {
        if (const err = texture.unlock)
        {
            throw new Exception(err.toString);
        }
    }

    override double opacity()
    {
        return super.opacity;
    }

    override bool opacity(double value)
    {
        assert(texture);

        bool isSet = super.opacity(value);
        if (!isSet)
        {
            return isSet;
        }

        if (const err = texture.setOpacity(value))
        {
            logger.error(err.toString);
        }

        return isSet;
    }

    void setRendererTarget()
    {
        assert(texture);
        if (const err = texture.setRendererTarget)
        {
            logger.error(err.toString);
        }
    }

    void restoreRendererTarget()
    {
        assert(texture);
        if (const err = texture.restoreRendererTarget)
        {
            logger.error(err.toString);
        }
    }

    override void dispose()
    {
        super.dispose;
        if (texture)
        {
            texture.dispose;
        }
    }
}
