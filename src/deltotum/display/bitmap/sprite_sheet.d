module deltotum.display.bitmap.sprite_sheet;

import std.stdio;

import deltotum.display.display_object : DisplayObject;

import deltotum.display.bitmap.bitmap : Bitmap;

//TODO extract interfaces
import deltotum.hal.sdl.sdl_texture : SdlTexture;
import deltotum.hal.sdl.sdl_renderer : SdlRenderer;
import deltotum.hal.sdl.img.sdl_image : SdlImage;
import deltotum.math.rect : Rect;

import bindbc.sdl;

private
{
    class SpriteSheetAnimation
    {
        @property string name;
        @property int[] frameIndices = [];
        @property int frameRow = 0;
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
        double frameWidth = 0;
        double frameHeight = 0;
    }

    this(int frameWidth = 0, int frameHeight = 0, int frameDelay = 100)
    {
        this.frameDelay = frameDelay;

        this.frameWidth = frameWidth;
        this.frameHeight = frameHeight;
    }

    override bool load(string path, int requestWidth = -1, int requestHeight = -1)
    {
        const isLoad = super.load(path, requestWidth, requestHeight);
        if (isLoad && frameWidth > 0 && frameHeight > 0)
        {
            width = frameWidth * scale;
            height = frameHeight * scale;
        }
        return isLoad;
    }
    
    void addAnimation(string name, int[] frameIndices, int frameRow = 0, bool autoplay = false)
    {
        assert(name.length > 0);
        //TODO check exists;
        auto anim = new SpriteSheetAnimation;
        anim.name = name;
        anim.frameIndices = frameIndices;
        anim.frameRow = frameRow;
        animations ~= anim;

        if (autoplay)
        {
            currentAnimation = anim;
        }
    }

    void playAnimation(string name, SDL_RendererFlip flip = SDL_RendererFlip.SDL_FLIP_NONE)
    {
        assert(name.length > 0);
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
        srcRect.x = cast(int)(frameWidth * frameIndex);
        srcRect.y = cast(int)(frameHeight * rowIndex);
        srcRect.width = cast(int) frameWidth;
        srcRect.height = cast(int) frameHeight;

        drawTexture(texture, srcRect, cast(int) x, cast(int) y, angle, flip);
    }

    override void drawFrames()
    {
        if (currentAnimation is null)
        {
            return;
        }

        const frameIndex = currentAnimation.frameIndices[currentAnimationIndex];
        const frameRow = currentAnimation.frameRow;

        drawFrame(x, y, width, height, frameIndex, frameRow, currentFlip);
    }

    override void update(double delta)
    {
        super.update(delta);

        if (currentAnimation is null)
        {
            return;
        }

        const animLength = currentAnimation.frameIndices.length;
        if (animLength > 0)
        {
            if (currentAnimationIndex >= currentAnimation.frameIndices.length - 1)
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
