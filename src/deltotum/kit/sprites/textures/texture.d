module deltotum.kit.sprites.textures.texture;

import deltotum.kit.sprites.sprite : Sprite;

import deltotum.com.gui.com_texture: ComTexture;
import deltotum.sys.sdl.sdl_surface : SdlSurface;
import deltotum.math.shapes.rect2d : Rect2d;
import deltotum.math.geom.flip : Flip;
import deltotum.kit.graphics.colors.rgba : RGBA;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class Texture : Sprite
{
    bool isDrawTexture = true;

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

    void loadFromSurface(SdlSurface surface)
    {
        auto newTexture = graphics.newComTexture;
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

        texture = newTexture;
    }

    void setBlendMode()
    {
        if (const err = texture.setModeBlend)
        {
            throw new Exception(err.toString);
        }
    }

    void setBlendNone()
    {
        if (const err = texture.setBlendNone)
        {
            throw new Exception(err.toString);
        }
    }

    override void drawContent()
    {
        if (texture is null)
        {
            //TODO logging
            return;
        }

        //draw parent first
        if (isDrawTexture)
        {
            Rect2d textureBounds = Rect2d(0, 0, width, height);
            //TODO flip, toInt?
            drawTexture(texture, textureBounds, cast(int) x, cast(int) y, angle);
        }

        super.drawContent;
    }

    void drawTexture(Rect2d textureBounds, Rect2d destBounds, double angle = 0, Flip flip = Flip
            .none)
    {
        if (const err = texture.draw(textureBounds, destBounds, angle, flip))
        {
            //TODO logging
        }
    }

    int drawTexture(ComTexture texture, Rect2d textureBounds, int x = 0, int y = 0, double angle = 0, Flip flip = Flip
            .none)
    {
        {
            //TODO compare double, where to set opacity?
            import std.math.operations : isClose;

            //!isClose(texture.opacity, opacity)
            if (texture.opacity != opacity)
            {
                texture.opacity = opacity;
            }
            Rect2d destBounds = Rect2d(x, y, width, height);
            return texture.draw(textureBounds, destBounds, angle, flip);
        }
    }

    bool setColor(RGBA color)
    {
        if (!texture)
        {
            return false;
        }
        if (const err = texture.setColor(color.r, color.g, color.b, color.aNorm))
        {
            throw new Exception(err.toString);
        }
        return true;
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
        import Math = deltotum.math;

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
        import Math = deltotum.math;

        if (texture && Math.abs(oldChangedHeight - value) > changeSizeDelta)
        {
            recreate;
            oldChangedHeight = value;
        }
    }

    // void setAlpha(double valueOto1)
    // {
    //     import std.conv : to;

    //     ubyte value = (valueOto1 * ubyte.max).to!ubyte;
    //     if (const err = texture.setAlphaMod(value))
    //     {
    //         throw new Exception(err.toString);
    //     }
    // }

    Texture copy()
    {
        assert(texture);
        ComTexture newTexture;
        if(const err = texture.copy(newTexture)){
            throw new Exception(err.toString);
        }
        auto texture = new Texture(newTexture);
        texture.initialize;
        return texture;
    }

    ComTexture nativeTexture() nothrow
    {
        return this.texture;
    }

    void lock(ref uint* pixels, out int pitch)
    {
        if (const err = texture.lock(pixels, pitch))
        {
            throw new Exception(err.toString);
        }
    }

    void changeColor(uint x, uint y, uint* pixels, uint pitch, RGBA color)
    {
        if (const err = texture.changeColor(x, y, pixels, pitch, color.r, color.g, color.b, color
                .aNorm))
        {
            throw new Exception(err.toString);
        }
    }

    void pixel(uint x, uint y, uint* pixels, uint pitch, ref uint* pixel)
    {
        if (const err = texture.pixel(x, y, pixels, pitch, pixel))
        {
            throw new Exception(err.toString);
        }
    }

    void unlock()
    {
        if (const err = texture.unlock)
        {
            throw new Exception(err.toString);
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
