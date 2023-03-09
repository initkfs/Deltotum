module deltotum.toolkit.display.images.animated_image;

import deltotum.toolkit.display.images.loadable_image : LoadableImage;
import deltotum.toolkit.display.display_object : DisplayObject;

//TODO extract interfaces
import deltotum.platform.sdl.sdl_texture : SdlTexture;
import deltotum.platform.sdl.sdl_renderer : SdlRenderer;
import deltotum.platform.sdl.img.sdl_image : SdlImage;
import deltotum.core.maths.shapes.rect2d : Rect2d;
import deltotum.toolkit.display.animation.interp.interpolator : Interpolator;
import deltotum.toolkit.display.animation.transition : Transition;
import std.math.rounding : floor;
import std.conv : to;
import deltotum.toolkit.display.flip : Flip;

import bindbc.sdl;

private
{
    class ImageAnimation
    {
        string name;
        int[] frameIndices;
        int frameRow;
        Transition!double transition;
        int frameDelay;
        bool isLooping;
    }
}

/**
 * Authors: initkfs
 */
class AnimatedImage : LoadableImage
{
    protected
    {
        int commonFrameDelay;

        ImageAnimation[] animations;
        ImageAnimation currentAnimation;
        size_t currentAnimationIndex;
        size_t currentAnimationStartTime;
        Flip currentFlip = Flip.none;
        double frameWidth = 0;
        double frameHeight = 0;
    }

    this(int frameWidth = 0, int frameHeight = 0, int commonFrameDelay = 100)
    {
        this.commonFrameDelay = commonFrameDelay;

        this.frameWidth = frameWidth;
        this.frameHeight = frameHeight;
        isDrawTexture = false;
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

    void addAnimation(string name, int[] frameIndices, int frameRow = 0, bool autoplay = false, int frameDelay = 0, bool isLooping = true, Interpolator interpolator = null)
    {
        assert(name.length > 0);
        //TODO check exists;
        auto anim = new ImageAnimation;
        anim.name = name;
        anim.frameIndices = frameIndices;
        anim.frameRow = frameRow;
        anim.isLooping = isLooping;
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
                if (currentFlip == flip)
                {
                    return;
                }
            }
            else
            {
                if (currentAnimation.transition !is null)
                {
                    currentAnimation.transition.stop;
                }
            }

        }

        currentAnimationIndex = 0;
        currentFlip = flip;

        foreach (anim; animations)
        {
            if (anim.name == name)
            {
                currentAnimation = anim;
                if (currentAnimation.transition !is null)
                {
                    currentAnimation.transition.run;
                }
            }
        }

        currentAnimationStartTime = SDL_GetTicks();
    }

    void drawFrame(int frameIndex, int rowIndex, Flip flip = Flip
            .none)
    {
        Rect2d srcRect;
        srcRect.x = cast(int)(frameWidth * frameIndex);
        srcRect.y = cast(int)(frameHeight * rowIndex);
        srcRect.width = cast(int) frameWidth;
        srcRect.height = cast(int) frameHeight;

        drawTexture(texture, srcRect, cast(int) x, cast(int) y, angle, flip);
    }

    void drawFrames()
    {
        if (currentAnimation is null)
        {
            return;
        }

        const frameIndex = currentAnimation.frameIndices[currentAnimationIndex];
        const frameRow = currentAnimation.frameRow;

        drawFrame(frameIndex, frameRow, currentFlip);
    }

    override void drawContent()
    {
        drawFrames;
        super.drawContent;
    }

    override void update(double delta)
    {
        super.update(delta);

        if (currentAnimation is null)
        {
            return;
        }

        immutable animLength = currentAnimation.frameIndices.length;
        if (animLength == 0)
        {
            return;
        }

        if (!currentAnimation.isLooping && currentAnimationIndex >= currentAnimation.frameIndices.length - 1)
        {
            return;
        }

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
            currentAnimationIndex = ((SDL_GetTicks() - currentAnimationStartTime) / delay) % animLength;
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
