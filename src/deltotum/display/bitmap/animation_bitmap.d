module deltotum.display.bitmap.animation_bitmap;

import std.stdio;

import deltotum.display.display_object : DisplayObject;

import deltotum.display.bitmap.bitmap : Bitmap;

//TODO extract interfaces
import deltotum.hal.sdl.sdl_texture : SdlTexture;
import deltotum.hal.sdl.sdl_renderer : SdlRenderer;
import deltotum.hal.sdl.img.sdl_image : SdlImage;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class AnimationBitmap : Bitmap
{
    protected
    {
        int currentFrame;
        int frameWidth;
        int frameHeight;
        int frameCount;
        int frameDelay;
    }

    this(int frameCount, int frameDelay = 100)
    {
        this.frameCount = frameCount;
        this.frameDelay = frameDelay;
    }

    override bool load(string path, int requestWidth = -1, int requestHeight = -1)
    {
        auto image = new SdlImage(path);
        texture = new SdlTexture;
        texture.fromRenderer(window.renderer, image);
        int width;
        int height;
        int result = texture.getSize(&width, &height);
        if (result != 0)
        {
            string error = "Unable to load image from " ~ path;
            if (const err = texture.getError)
            {
                error ~= err;
            }
            logger.errorf(error);
            return false;
        }

        frameWidth = width / frameCount;
        frameHeight = height;

        this.width = frameWidth;
        this.height = frameHeight;

        image.destroy;
        return true;
    }

    void drawFrame(double x, double y, int width, int height, int currentRow, int currentFrame, SDL_RendererFlip flip = SDL_RendererFlip
            .SDL_FLIP_NONE)
    {
        SDL_Rect srcRect;
        SDL_Rect destRect;
        srcRect.x = width * currentFrame;
        srcRect.y = height * (currentRow - 1);

        srcRect.w = width;
        destRect.w = width;

        srcRect.h = width;
        destRect.h = height;

        destRect.x = cast(int) x;
        destRect.y = cast(int) y;

        SDL_Point center = {0, 0};
        window.renderer.copyEx(texture, &srcRect, &destRect, 0, &center, flip);
    }

    override void drawContent()
    {
        super.drawContent;
        drawFrame(x, y, frameWidth, frameHeight, 1, currentFrame);
    }

    override void update(double delta)
    {
        super.update(delta);
        currentFrame = int(((SDL_GetTicks() / frameDelay) % frameCount));
    }
}
