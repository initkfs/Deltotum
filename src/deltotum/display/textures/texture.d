module deltotum.display.textures.texture;

import deltotum.display.display_object : DisplayObject;

import deltotum.hal.sdl.sdl_texture : SdlTexture;
import deltotum.math.shapes.rect2d : Rect2d;
import std.math.operations : isClose;
import deltotum.display.flip : Flip;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class Texture : DisplayObject
{
    @property bool isDrawTexture = true;

    protected
    {
        SdlTexture texture;
    }

    this()
    {

    }

    this(SdlTexture texture)
    {
        this.texture = texture;
        int w, h;
        texture.getSize(&w, &h);
        this.width = w;
        this.height = h;
    }

    override void drawContent()
    {
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
            SDL_Rect srcRect;
            srcRect.x = cast(int) textureBounds.x;
            srcRect.y = cast(int) textureBounds.y;
            srcRect.w = cast(int) textureBounds.width;
            srcRect.h = cast(int) textureBounds.height;

            Rect2d bounds = window.getScaleBounds;

            SDL_Rect destRect;
            destRect.x = cast(int)(x + bounds.x);
            destRect.y = cast(int)(y + bounds.y);
            destRect.w = cast(int) width;
            destRect.h = cast(int) height;

            //FIXME some texture sizes can crash when changing the angle
            //double newW = height * abs(Math.sinDeg(angle)) + width * abs(Math.cosDeg(angle));
            //double newH = height * abs(Math.cosDeg(angle)) + width * abs(Math.sinDeg(angle));

            //TODO compare double
            if (!isClose(texture.opacity, opacity))
            {
                texture.opacity = opacity;
            }

            //TODO move to helper
            SDL_RendererFlip sdlFlip;
            final switch (flip)
            {
            case Flip.none:
                sdlFlip = SDL_RendererFlip.SDL_FLIP_NONE;
                break;
            case Flip.horizontal:
                sdlFlip = SDL_RendererFlip.SDL_FLIP_HORIZONTAL;
                break;
            case Flip.vertical:
                sdlFlip = SDL_RendererFlip.SDL_FLIP_VERTICAL;
                break;
            }

            return window.renderer.copyEx(texture, &srcRect, &destRect, angle, null, sdlFlip);
        }
    }

    SdlTexture nativeTexture()
    {
        return this.texture;
    }

    override void destroy()
    {
        super.destroy;
        texture.destroy;
    }
}
