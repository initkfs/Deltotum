module dm.kit.sprites.textures.texture;

import dm.kit.sprites.sprite : Sprite;

import dm.com.graphics.com_texture : ComTexture;
import dm.com.graphics.com_surface : ComSurface;
import dm.com.graphics.com_blend_mode : ComBlendMode;
import dm.math.shapes.rect2d : Rect2d;
import dm.math.geom.flip : Flip;
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
        double changeSizeDelta = 10;
    }

    this()
    {

    }

    this(double width, double height)
    {
        width = width;
        height = height;
    }

    this(ComTexture texture)
    {
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

        if (texture && Math.abs(oldChangedWidth - value) > changeSizeDelta)
        {
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
            recreate;
            oldChangedHeight = value;
        }
    }

    override void recreate()
    {
        //isCreated = false;
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
        auto texture = new Texture(newTexture);
        build(texture);
        texture.initialize;
        texture.create;
        return texture;
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

    override void dispose()
    {
        super.dispose;
        if (texture)
        {
            texture.dispose;
        }
    }
}
