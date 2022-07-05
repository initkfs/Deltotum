module deltotum.display.bitmap.sprite_sheet;

import std.stdio;

import deltotum.display.display_object : DisplayObject;

import deltotum.display.bitmap.bitmap : Bitmap;

//TODO extract interfaces
import deltotum.hal.sdl.sdl_texture : SdlTexture;
import deltotum.hal.sdl.sdl_renderer : SdlRenderer;
import deltotum.hal.sdl.img.sdl_image : SdlImage;

import bindbc.sdl;

private
{
    class SpriteSheetAnimation
    {
        @property string name;
        @property int[] indices = [];
        @property int row = 0;
    }
}

/**
 * Authors: initkfs
 */
class SpriteSheet : Bitmap
{
    protected
    {
        int frameDelay;

        SpriteSheetAnimation[] animations = [];
        SpriteSheetAnimation currentAnimation;
        uint currentAnimationIndex;
    }

    this(int frameWidth, int frameHeight, int frameDelay = 100)
    {
        this.frameDelay = frameDelay;

        this.width = frameWidth;
        this.height = frameHeight;
    }

    override bool load(string path, int requestWidth = -1, int requestHeight = -1)
    {
        auto frameWidth = width;
        auto frameHeight = height;
        const isLoad = super.load(path, requestWidth, requestHeight);
        if (isLoad)
        {
            width = frameWidth;
            height = frameHeight;
        }
        return isLoad;
    }

    void addAnimation(string name, int[] indices, int row = 0, bool autoplay = true)
    {
        //TODO check exists;
        auto anim = new SpriteSheetAnimation;
        anim.name = name;
        anim.indices = indices;
        anim.row = row;
        animations ~= anim;

        if (autoplay)
        {
            currentAnimation = anim;
        }
    }

    void playAnimation(string name)
    {
        foreach (anim; animations)
        {
            if (anim.name == name)
            {
                currentAnimation = anim;
            }
        }
    }

    void drawFrame(double x, double y, double width, double height, int frameIndex, int rowIndex, SDL_RendererFlip flip = SDL_RendererFlip
            .SDL_FLIP_NONE)
    {
        SDL_Rect srcRect;
        SDL_Rect destRect;

        //TODO remove casts
        srcRect.x = cast(int) (width * frameIndex);
        srcRect.y = cast(int) (height * rowIndex);

        srcRect.w = cast(int) width;
        destRect.w = cast(int) width;

        srcRect.h = cast(int) width;
        destRect.h = cast(int) height;

        destRect.x = cast(int) x;
        destRect.y = cast(int) y;

        SDL_Point center = {0, 0};
        window.renderer.copyEx(texture, &srcRect, &destRect, 0, &center, flip);
    }

    override void drawContent()
    {
        if (currentAnimation is null)
        {
            return;
        }

        const frameIndex = currentAnimation.indices[currentAnimationIndex];
        const frameRow = currentAnimation.row;

        drawFrame(x, y, width, height, frameIndex, frameRow);
    }

    override void update(double delta)
    {
        super.update(delta);
        const animLength = currentAnimation.indices.length;
        if (animLength > 0)
        {
            if (currentAnimationIndex >= currentAnimation.indices.length - 1)
            {
                currentAnimationIndex = 0;
            }
            else
            {
                currentAnimationIndex = (SDL_GetTicks() / frameDelay) % animLength;
            }
        }
    }
}
