module deltotum.images.animated_image;

import std.stdio;

import deltotum.display.display_object : DisplayObject;

import deltotum.images.image : Image;

//TODO extract interfaces
import deltotum.hal.sdl.sdl_texture : SdlTexture;
import deltotum.hal.sdl.sdl_renderer : SdlRenderer;
import deltotum.hal.sdl.img.sdl_image : SdlImage;
import deltotum.math.rect : Rect;
import deltotum.animation.interp.interpolator : Interpolator;
import deltotum.animation.transition : Transition;
import std.math.rounding : floor;
import std.conv : to;
import deltotum.display.flip: Flip;

import bindbc.sdl;

private
{
    class ImageAnimation
    {
        @property string name;
        @property int[] frameIndices = [];
        @property int frameRow;
        @property Transition!double transition;
        @property int frameDelay;
    }
}

/**
 * Authors: initkfs
 */
class AnimatedImage : Image
{
    protected
    {
        int commonFrameDelay;

        ImageAnimation[] animations = [];
        ImageAnimation currentAnimation;
        size_t currentAnimationIndex;
        Flip currentFlip = Flip.none;
        double frameWidth = 0;
        double frameHeight = 0;
    }

    this(int frameWidth = 0, int frameHeight = 0, int commonFrameDelay = 100)
    {
        this.commonFrameDelay = commonFrameDelay;

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

    void addAnimation(string name, int[] frameIndices, int frameRow = 0, bool autoplay = false, int frameDelay = 0, Interpolator interpolator = null)
    {
        assert(name.length > 0);
        //TODO check exists;
        auto anim = new ImageAnimation;
        anim.name = name;
        anim.frameIndices = frameIndices;
        anim.frameRow = frameRow;
        anim.frameDelay = frameDelay > 0 ? frameDelay : commonFrameDelay;
        if (interpolator !is null)
        {
            anim.transition = new Transition!double(0, 1, anim.frameDelay, interpolator);
            build(anim.transition);
        }
        animations ~= anim;

        if (autoplay)
        {
            playAnimation(name);
        }
    }

    void playAnimation(string name, Flip flip = Flip.none)
    {
        assert(name.length > 0);
        if (currentAnimation !is null)
        {
            if (currentAnimation.name == name)
            {
                return;
            }
            else
            {
                if (currentAnimation.transition !is null)
                {
                    currentAnimation.transition.stop;
                }
            }

        }

        foreach (anim; animations)
        {
            if (anim.name == name)
            {
                currentAnimation = anim;
                if (currentAnimation.transition !is null)
                {
                    currentAnimation.transition.run;
                }
                currentAnimationIndex = 0;
                this.currentFlip = flip;
            }
        }
    }

    void drawFrame(double x, double y, double width, double height, int frameIndex, int rowIndex, Flip flip = Flip.none)
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
                if (currentAnimation.transition !is null)
                {
                    currentAnimation.transition.update(delta);
                    const progress0to1 = currentAnimation.transition.lastValue;
                    const indicesLength = currentAnimation.frameIndices.length;
                    //TODO smooth
                    int index = to!int(progress0to1 * indicesLength * (1 - double.epsilon));
                    if (index > 0 && index < indicesLength)
                    {
                        currentAnimationIndex = index;
                    }
                }
                else
                {
                    auto delay = currentAnimation.frameDelay > 0 ? currentAnimation.frameDelay
                        : commonFrameDelay;
                    currentAnimationIndex = (SDL_GetTicks() / delay) % animLength;
                }

            }
        }
    }

    override void destroy()
    {
        super.destroy;
        foreach (ImageAnimation animation; animations)
        {
            if (animation.transition !is null)
            {
                animation.transition.stop;
                animation.transition.destroy;
            }
        }
        animations = [];
    }
}
