module deltotum.display.display_object;

import deltotum.application.components.uni.uni_component : UniComponent;

import deltotum.math.vector2d : Vector2D;
import deltotum.math.rect : Rect;
import deltotum.hal.sdl.sdl_texture : SdlTexture;
import deltotum.physics.physical_body : PhysicalBody;

import std.math.operations : isClose;
import std.stdio;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
abstract class DisplayObject : PhysicalBody
{

    @property double x = 0;
    @property double y = 0;
    @property double width = 0;
    @property double height = 0;
    @property Vector2D* velocity;
    @property Vector2D* acceleration;
    @property bool isRedraw = false;
    @property double opacity = 1;
    @property double angle = 0;
    @property double scale = 1;

    this()
    {
        super();
        //use initialization in constructor
        //TODO move to physical body?
        velocity = new Vector2D;
        acceleration = new Vector2D;
    }

    void drawContent()
    {

    }

    int drawTexture(SdlTexture texture, Rect textureBounds, int x = 0, int y = 0, double angle = 0, SDL_RendererFlip flip = SDL_RendererFlip
            .SDL_FLIP_NONE)
    {
        {
            SDL_Rect srcRect;
            srcRect.x = cast(int) textureBounds.x;
            srcRect.y = cast(int) textureBounds.y;
            srcRect.w = cast(int) textureBounds.width;
            srcRect.h = cast(int) textureBounds.height;

            Rect bounds = window.getScaleBounds;

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
            return window.renderer.copyEx(texture, &srcRect, &destRect, angle, null, flip);
        }
    }

    final bool draw()
    {
        //TODO layer
        drawContent;
        return true;
    }

    void requestRedraw()
    {
        isRedraw = true;
    }

    void update(double delta)
    {
        velocity.x += acceleration.x * delta;
        velocity.y += acceleration.y * delta;
        x += velocity.x * delta;
        y += velocity.y * delta;
    }

    Rect bounds()
    {
        const Rect bounds = {x, y, width, height};
        return bounds;
    }

    void destroy()
    {

    }
}
