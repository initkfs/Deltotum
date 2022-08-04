module deltotum.display.textures.texture;

import deltotum.display.display_object : DisplayObject;

import deltotum.hal.sdl.sdl_texture : SdlTexture;
import deltotum.math.rect : Rect;
import std.math.operations : isClose;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class Texture : DisplayObject
{
    protected
    {
        SdlTexture texture;
    }

    this(){

    }

    this(SdlTexture texture){
        this.texture = texture;
        int w, h;
        texture.getSize(&w, &h);
        this.width = w;
        this.height = h;
    }

    void createTextureContent(){

    }

    override void drawContent()
    {
        Rect textureBounds = Rect(0, 0, width, height);
        //TODO flip, toInt?
        drawTexture(texture, textureBounds, cast(int) x, cast(int) y, angle);
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

    SdlTexture nativeTexture(){
        return this.texture;
    }

    override void destroy()
    {
        super.destroy;
        texture.destroy;
    }
}
