module dm.kit.sprites.textures.texture;

import dm.kit.sprites.sprite : Sprite;

import dm.com.graphics.com_texture : ComTexture;
import dm.com.graphics.com_surface : ComSurface;
import dm.com.graphics.com_blend_mode : ComBlendMode;
import dm.com.graphics.com_texture_scale_mode : ComTextureScaleMode;
import dm.math.rect2d : Rect2d;
import dm.math.flip : Flip;
import dm.kit.graphics.colors.rgba : RGBA;

/**
 * Authors: initkfs
 */
class Texture : Sprite
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

    }

    this(double width, double height)
    {
        this.width = width;
        this.height = height;
    }

    this(ComTexture texture)
    {
        assert(texture);

        int w, h;
        if (const sizeErr = texture.getSize(w, h))
        {
            throw new Exception(sizeErr.toString);
        }

        this.width = w;
        this.height = h;

        this.texture = texture;
    }

    void loadFromSurface(ComSurface surface)
    {
        auto newTexture = texture;
        if (!newTexture)
        {
            newTexture = graphics.comTextureProvider.getNew();
        }
        else
        {
            texture = null;
        }

        if (const err = newTexture.fromSurface(surface))
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
        assert(width > 0 && height > 0);

        texture = graphics.comTextureProvider.getNew();
        if (const err = texture.createMutRGBA32(cast(int) width, cast(int) height))
        {
            throw new Exception(err.toString);
        }
    }

    void createTargetRGBA32()
    {
        assert(width > 0 && height > 0);
        assert(graphics);

        texture = graphics.comTextureProvider.getNew();
        if (const err = texture.createTargetRGBA32(cast(int) width, cast(int) height))
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

        enforce(texture, "Texture not created");
        if (const err = texture.setColor(color.r, color.g, color.b, color.aByte))
        {
            throw new Exception(err.toString);
        }
    }

    RGBA color()
    {
        import std.exception : enforce;

        enforce(texture, "Texture not created");
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

    override void width(double value)
    {
        super.width(value);
        if (!isResizable)
        {
            return;
        }
        import Math = dm.math;

        if (texture && texture.isCreated && Math.abs(oldChangedWidth - value) > changeSizeDelta)
        {
            if (onPreRecreateWidthOldNew)
            {
                onPreRecreateHeightOldNew(oldChangedWidth, width);
            }
            recreate;
            oldChangedWidth = width;
        }
    }

    override double height()
    {
        return super.height;
    }

    override void height(double value)
    {
        super.height(value);
        if (!isResizable)
        {
            return;
        }
        import Math = dm.math;

        if (texture && Math.abs(oldChangedHeight - value) > changeSizeDelta)
        {
            if (onPreRecreateHeightOldNew)
            {
                onPreRecreateHeightOldNew(oldChangedHeight, value);
            }
            recreate;
            oldChangedHeight = value;
        }
    }

    override void recreate()
    {
        create;
    }

    Texture copy()
    {
        assert(texture);
        ComTexture newTexture;
        if (const err = texture.copy(newTexture))
        {
            throw new Exception(err.toString);
        }
        auto toTexture = new Texture(newTexture);
        build(toTexture);
        toTexture.initialize;
        toTexture.create;
        return toTexture;
    }

    void copyFrom(Texture other)
    {
        Rect2d srcRect = {0, 0, other.width, other.height};
        Rect2d destRect = {0, 0, width, height};
        copyFrom(other, srcRect, destRect);
    }

    void copyFrom(Texture other, Rect2d srcRect, Rect2d dstRect)
    {
        assert(texture);
        if (const err = texture.copyFrom(other.nativeTexture, srcRect, dstRect, other.angle, other
                .flip))
        {
            throw new Exception(err.toString);
        }
    }

    inout(ComTexture) nativeTexture() inout @nogc nothrow
    {
        return this.texture;
    }

    void lock()
    {
        assert(texture && !texture.isLocked);
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

    uint* pixel(uint x, uint y)
    {
        assert(texture && texture.isLocked);
        uint* ptr;
        if (const err = texture.getPixel(x, y, ptr))
        {
            throw new Exception(err.toString);
        }
        return ptr;
    }

    RGBA[][] pixelColors()
    {
        assert(width > 0 && height > 0);
        RGBA[][] buff = new RGBA[][](cast(size_t) height, cast(size_t) width);
        pixelColors(buff);
        return buff;
    }

    void pixelColors(RGBA[][] buff)
    {
        assert(width > 0);
        assert(height > 0);
        assert(texture && texture.isLocked);
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

    RGBA pixelColor(uint x, uint y)
    {
        assert(texture && texture.isLocked);
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

    override void opacity(double value)
    {
        assert(texture);
        super.opacity(value);
        if (const err = texture.changeOpacity(value))
        {
            logger.error(err.toString);
        }
    }

    void setRendererTarget()
    {
        if (const err = texture.setRendererTarget)
        {
            logger.error(err.toString);
        }
    }

    void resetRendererTarget()
    {
        if (const err = texture.resetRendererTarget)
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
