module deltotum.display.textures.texture;

import deltotum.display.display_object : DisplayObject;

import deltotum.platforms.sdl.sdl_texture : SdlTexture;
import deltotum.platforms.sdl.sdl_surface : SdlSurface;
import deltotum.math.shapes.rect2d : Rect2d;
import deltotum.display.flip : Flip;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class Texture : DisplayObject
{
    bool isDrawTexture = true;

    protected
    {
        SdlTexture texture;
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
        auto newTexture = new SdlTexture;
        if(const err = newTexture.fromRenderer(window.renderer, surface)){
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

    int drawTexture(SdlTexture texture, Rect2d textureBounds, int x = 0, int y = 0, double angle = 0, Flip flip = Flip
            .none)
    {
        {
            //TODO compare double, where to set opacity?
            import std.math.operations : isClose;

            if (!isClose(texture.opacity, opacity))
            {
                texture.opacity = opacity;
            }
            Rect2d destBounds = Rect2d(x, y, width, height);
            return window.renderer.drawTexture(texture, textureBounds, destBounds, angle, flip);
        }
    }

    SdlTexture nativeTexture()
    {
        return this.texture;
    }

    override void destroy()
    {
        super.destroy;
        if (texture !is null)
        {
            texture.destroy;
        }
    }
}
