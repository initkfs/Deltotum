module deltotum.display.bitmap.sprite_sheet;

import std.stdio;

import deltotum.display.display_object : DisplayObject;

import deltotum.display.bitmap.bitmap : Bitmap;

//TODO extract interfaces
import deltotum.hal.sdl.sdl_texture : SdlTexture;
import deltotum.hal.sdl.sdl_renderer : SdlRenderer;
import deltotum.hal.sdl.img.sdl_image : SdlImage;
import deltotum.math.rect: Rect;

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
        size_t currentAnimationIndex;
        SDL_RendererFlip currentFlip = SDL_RendererFlip.SDL_FLIP_NONE;
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

    void addAnimation(string name, int[] indices, int row = 0, bool autoplay = false)
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

    void playAnimation(string name, SDL_RendererFlip flip = SDL_RendererFlip.SDL_FLIP_NONE)
    {
        if (currentAnimation !is null && currentAnimation.name == name)
        {
            return;
        }

        foreach (anim; animations)
        {
            if (anim.name == name)
            {
                currentAnimation = anim;
                currentAnimationIndex = 0;
                this.currentFlip = flip;
            }
        }
    }

    void drawFrame(double x, double y, double width, double height, int frameIndex, int rowIndex, SDL_RendererFlip flip = SDL_RendererFlip
            .SDL_FLIP_NONE)
    {
        Rect srcRect;
        srcRect.x = cast(int)(width * frameIndex);
        srcRect.y = cast(int)(height * rowIndex);
        srcRect.width = cast(int) width;
        srcRect.height = cast(int) height;

        drawTexture(texture, srcRect, cast(int) x, cast(int) y, flip);
    }

    override void drawContent()
    {
        if (currentAnimation is null)
        {
            return;
        }

        const frameIndex = currentAnimation.indices[currentAnimationIndex];
        const frameRow = currentAnimation.row;

        drawFrame(x, y, width, height, frameIndex, frameRow, currentFlip);
    }

    override void update(double delta)
    {
        super.update(delta);

        if (currentAnimation is null)
        {
            return;
        }

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
