module deltotum.display.display_object;

import deltotum.application.components.uni.uni_component : UniComponent;

import deltotum.math.vector2d : Vector2D;
import deltotum.math.rect : Rect;
import deltotum.hal.sdl.sdl_texture : SdlTexture;
import deltotum.physics.physical_body: PhysicalBody;


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

    void drawTexture(SdlTexture texture, Rect textureBounds, int x = 0, int y = 0, SDL_RendererFlip flip = SDL_RendererFlip
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
            SDL_Point center = {0, 0};
            window.renderer.copyEx(texture, &srcRect, &destRect, 0, &center, flip);
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
