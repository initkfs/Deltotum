module api.dm.kit.sprites.images.animated_image;

import api.dm.kit.sprites.images.image : Image;
import api.dm.kit.sprites.sprite : Sprite;

import api.math.geom2.rect2 : Rect2d;
import api.dm.kit.sprites.transitions.curves.interpolator : Interpolator;
import api.dm.kit.sprites.transitions.min_max_transition : MinMaxTransition;
import std.math.rounding : floor;
import std.conv : to;
import api.math.flip : Flip;

private
{
    class ImageAnimation
    {
        string name;
        int[] frameIndices;
        int frameRow;
        MinMaxTransition!double transition;
        int frameDelay;
        bool isLooping;
    }
}

/**
 * Authors: initkfs
 */
class AnimatedImage : Image
{
    int frameDelay;
    double frameWidth = 0;
    double frameHeight = 0;

    enum defaultAnimation = "idle";

    void delegate()[] onEndFrames;

    protected
    {
        ImageAnimation[] animations;

        ImageAnimation currentAnimation;
        size_t currentAnimationIndex;
        size_t currentAnimationStartTime;

        Flip currentFlip = Flip.none;
    }

    this(int frameWidth = 0, int frameHeight = 0, int frameDelay = 0)
    {
        this.frameDelay = frameDelay;

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

    void addIdle(size_t frameCount, int frameRow = 0, bool autoplay = false, int frameDelay = 0, bool isLooping = true, Interpolator interpolator = null)
    {
        add(defaultAnimation, frameCount, frameRow, autoplay, frameDelay, isLooping, interpolator);
    }

    void add(string name, size_t frameCount, int frameRow = 0, bool autoplay = false, int frameDelay = 0, bool isLooping = true, Interpolator interpolator = null)
    {
        int[] frameIndices = new int[](frameCount);
        foreach (i; 0 .. frameCount)
        {
            frameIndices[i] = cast(int) i;
        }
        add(name, frameIndices, frameRow, autoplay, frameDelay, isLooping, interpolator);
    }

    void add(string name, int[] frameIndices, int frameRow = 0, bool autoplay = false, int frameDelay = 0, bool isLooping = true, Interpolator interpolator = null)
    {
        assert(name.length > 0);
        //TODO check exists;
        auto anim = new ImageAnimation;
        anim.name = name;
        anim.frameIndices = frameIndices;
        anim.frameRow = frameRow;
        anim.isLooping = isLooping;
        anim.frameDelay = frameDelay > 0 ? frameDelay : this.frameDelay;
        if (interpolator !is null)
        {
            anim.transition = new MinMaxTransition!double(0, 1, anim.frameDelay, interpolator);
            build(anim.transition);
        }
        animations ~= anim;

        if (autoplay)
        {
            run(name);
        }
    }

    import api.core.components.units.simple_unit : SimpleUnit;

    override void run(){
        super.run;
    }

    void run(string name, Flip flip = Flip.none)
    {
        assert(name.length > 0);

        if (currentAnimation)
        {
            if (isRunning && currentAnimation.name == name)
            {
                return;
            }

            if (currentAnimation.transition)
            {
                currentAnimation.transition.stop;
            }

        }

        if(isRunning){
            stop;
        }

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

        currentAnimationStartTime = platform.ticks;
        
        super.run;
        assert(isRunning);
    }

    void runIdle()
    {
        run(defaultAnimation);
    }

    bool frameIndex(size_t index)
    {
        if (!currentAnimation)
        {
            return false;
        }
        if (index >= currentAnimation.frameIndices.length)
        {
            return false;
        }
        auto newIndex = currentAnimation.frameIndices[index];
        if (currentAnimationIndex == newIndex)
        {
            return false;
        }
        currentAnimationIndex = newIndex;
        return true;
    }

    override void stop()
    {
        super.stop;
        currentAnimationIndex = 0;
    }

    void drawFrame(int frameIndex, int rowIndex, Flip flip = Flip
            .none)
    {
        Rect2d srcRect;
        srcRect.x = cast(int)(frameWidth * frameIndex);
        srcRect.y = cast(int)(frameHeight * rowIndex);
        srcRect.width = cast(int) frameWidth;
        srcRect.height = cast(int) frameHeight;

        assert(texture);
        Rect2d destRect = {x, y, width, height};
        drawTexture(texture, srcRect, destRect, angle, flip);
    }

    void drawFrames()
    {
        if (!currentAnimation)
        {
            return;
        }

        const frameIndex = currentAnimation.frameIndices[currentAnimationIndex];
        const frameRow = currentAnimation.frameRow;

        drawFrame(frameIndex, frameRow, currentFlip);
    }

    import std.typecons: Nullable;

    Nullable!ImageAnimation findByName(string name){
        foreach (anim; animations)
        {
            if(anim.name == name){
                return Nullable!ImageAnimation(anim);
            }
        }

        return Nullable!ImageAnimation.init;
    }

    override void drawContent()
    {
        drawFrames;
        super.drawContent;
    }

    override void update(double delta)
    {
        super.update(delta);

        if (!isRunning || !currentAnimation)
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
            foreach (dg; onEndFrames)
            {
                dg();
            }
            stop;
            return;
        }

        if (currentAnimation.transition)
        {
            currentAnimation.transition.update(delta);
            const progress0to1 = currentAnimation.transition.lastValue;
            const indicesLength = currentAnimation.frameIndices.length;
            //TODO smooth
            int index = cast(int)(progress0to1 * indicesLength * (1 - double.epsilon));
            if (index > 0 && index < indicesLength)
            {
                currentAnimationIndex = index;
            }
        }
        else
        {
            auto delay = currentAnimation.frameDelay > 0 ? currentAnimation.frameDelay : frameDelay;
            currentAnimationIndex = ((platform.ticks - currentAnimationStartTime) / delay) % animLength;
        }
    }

    double frameWidthHalf() => frameWidth / 2;
    double frameHeightHalf() => frameHeight / 2;

    override void dispose()
    {
        super.dispose;
        foreach (ImageAnimation animation; animations)
        {
            if (animation.transition !is null)
            {
                animation.transition.stop;
                animation.transition.dispose;
            }
        }
        animations = [];
    }
}
