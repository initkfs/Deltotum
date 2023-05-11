module deltotum.kit.sprites.textures.texture;

import deltotum.kit.sprites.sprite : Sprite;

import deltotum.sys.sdl.sdl_texture : SdlTexture;
import deltotum.sys.sdl.sdl_surface : SdlSurface;
import deltotum.math.shapes.rect2d : Rect2d;
import deltotum.kit.sprites.flip : Flip;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class Texture : Sprite
{
    bool isDrawTexture = true;

    protected
    {
        SdlTexture texture;
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

    this(SdlTexture texture)
    {
        int w, h;
        if (const sizeErr = texture.getSize(&w, &h))
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
        if (const sizeErr = newTexture.getSize(&w, &h))
        {
            throw new Exception(sizeErr.toString);
        }

        this.width = w;
        this.height = h;

        texture = newTexture;
    }

    void setBlendMode()
    {
        if (const err = texture.setBlendModeBlend)
        {
            throw new Exception(err.toString);
        }
    }

    void setBlendNone()
    {
        if (const err = texture.setBlendModeNone)
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

    int drawTexture(SdlTexture texture, Rect2d textureBounds, int x = 0, int y = 0, double angle = 0, Flip flip = Flip
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
            create;
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
            create;
            oldChangedHeight = value;
        }
    }

    SdlTexture nativeTexture() nothrow
    {
        return this.texture;
    }

    override void destroy()
    {
        super.destroy;
        if (texture)
        {
            texture.destroy;
        }
    }
}
