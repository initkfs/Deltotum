module api.dm.kit.sprites2d.images.anim_image;

import api.dm.kit.sprites2d.images.image : Image;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;

import api.math.geom2.rect2 : Rect2d;
import std.math.rounding : floor;
import std.conv : to;
import api.math.pos2.flip : Flip;

class ImageAnimation
{
    string name;
    int[] frameIndices;
    int frameRow;
    int maxFrameRows;
    bool isLoopRow;
    int frameDelay;
    bool isLooping;
    bool isReverse;
    Flip flip;
    void delegate() onEndFrames;
}

/**
 * Authors: initkfs
 */
class AnimImage : Image
{
    int frameDelay;

    size_t frameCols;
    size_t frameRows;

    double frameWidth = 0;
    double frameHeight = 0;

    protected
    {
        double _textureWidth = 0;
        double _textureHeight = 0;
    }

    enum defaultAnimation = "idle";

    void delegate()[] onEndFrames;

    protected
    {
        ImageAnimation[] animations;

        ImageAnimation currentAnimation;
        size_t currentAnimationIndex;
        size_t currentAnimationStartTime;
    }

    this(size_t frameCols, size_t frameRows, int frameWidth = 0, int frameHeight = 0, int frameDelay = 0)
    {
        this.frameCols = frameCols;
        this.frameRows = frameRows;

        this.frameWidth = frameWidth;
        this.frameHeight = frameHeight;

        this.frameDelay = frameDelay;

        isDrawTexture = false;
    }

    override void load(string path, int requestWidth = -1, int requestHeight = -1)
    {
        super.load(path, requestWidth, requestHeight);

        if (frameWidth == 0)
        {
            if (frameCols == 0)
            {
                throw new Exception("Cannot set frame width: number of columns is zero");
            }

            if (width == 0)
            {
                throw new Exception("Cannot set frame width: texture width is zero");
            }
            frameWidth = width / frameCols;
        }

        if (frameHeight == 0)
        {
            if (frameRows == 0)
            {
                throw new Exception("Cannot set frame height: number of rows is zero");
            }

            if (height == 0)
            {
                throw new Exception("Cannot set frame height: texture height is zero");
            }
            frameHeight = height / frameRows;
        }

        _textureWidth = width;
        _textureHeight = height;

        width = frameWidth * scale;
        height = frameHeight * scale;
    }

    bool addIdle(size_t frameCount, int frameRow = 0, bool autoplay = false, int frameDelay = 0, bool isLooping = true, Flip flip = Flip
            .none, int maxFrameRows = 1, bool isLoopRow = true)
    {
        return animate(defaultAnimation, frameCount, frameRow, autoplay, frameDelay, isLooping, flip, maxFrameRows, isLoopRow);
    }

    bool animate(string name, size_t frameCount, int frameRow = 0, bool autoplay = false, int frameDelay = 0, bool isLooping = true, Flip flip = Flip
            .none, int maxFrameRows = 1, bool isLoopRow = true)
    {
        if (frameCount == 0)
        {
            return false;
        }

        int[] frameIndices = new int[](frameCount);
        foreach (i; 0 .. frameCount)
        {
            frameIndices[i] = cast(int) i;
        }
        return animate(name, frameIndices, frameRow, autoplay, frameDelay, isLooping, flip, maxFrameRows, isLoopRow);
    }

    bool animate(string name, int[] frameIndices, int frameRow = 0, bool autoplay = false, int frameDelay = 0, bool isLooping = true, Flip newFlip = Flip
            .none, int maxFrameRows = 1, bool isLoopRow = true)
    {
        assert(name.length > 0);
        assert(frameIndices.length > 0);

        foreach (currAnim; animations)
        {
            if (name == currAnim.name)
            {
                return false;
            }
        }

        auto anim = new ImageAnimation;
        anim.name = name;
        anim.frameIndices = frameIndices;
        anim.frameRow = frameRow;
        anim.maxFrameRows = maxFrameRows;
        anim.isLoopRow = isLoopRow;
        anim.isLooping = isLooping;
        anim.frameDelay = frameDelay > 0 ? frameDelay : this.frameDelay;
        anim.flip = newFlip;

        animations ~= anim;

        if (autoplay)
        {
            run(name);
        }

        return true;
    }

    bool addOnEndFrame(string name, void delegate() dg)
    {
        auto anim = animationUnsafe(name);
        if (!anim)
        {
            return false;
        }
        anim.onEndFrames = dg;
        return true;
    }

    override void run()
    {
        super.run;
    }

    void run(string name, Flip flip = Flip.none)
    {
        assert(name.length > 0);

        if (isRunning)
        {

            if (currentAnimation.name == name)
            {
                return;
            }

            stop;
        }

        auto mustBeAnim = animationUnsafe(name);
        if (!mustBeAnim)
        {
            return;
        }

        currentAnimation = mustBeAnim;

        if (currentAnimation.flip == Flip.none && flip != Flip.none)
        {
            currentAnimation.flip = flip;
        }

        currentAnimationStartTime = platform.timer.ticksMs;

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

        auto newIndex = !currentAnimation.isReverse ? currentAnimation
            .frameIndices[index] : currentAnimation.frameIndices[$ - 1 - index];

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
        srcRect.x = frameWidth * frameIndex;
        srcRect.y = frameHeight * rowIndex;
        srcRect.width = frameWidth;
        srcRect.height = frameHeight;

        Flip animFlip = (currentAnimation && currentAnimation.flip != Flip.none) ? currentAnimation.flip
            : flip;

        assert(texture);
        Rect2d destRect = {x, y, width, height};
        drawTexture(texture, srcRect, destRect, angle, animFlip);
    }

    void drawFrames()
    {
        if (!currentAnimation)
        {
            return;
        }

        const frameIndex = currentAnimation.frameIndices[currentAnimationIndex];
        const frameRow = currentAnimation.frameRow;

        const newFlip = this.flip != Flip.none ? flip : currentAnimation.flip;

        drawFrame(frameIndex, frameRow, newFlip);
    }

    ImageAnimation animationUnsafe(string name)
    {
        foreach (anim; animations)
        {
            if (anim.name == name)
            {
                return anim;
            }
        }

        return null;
    }

    bool hasAnimation(string name) => animationUnsafe(name) !is null;

    import std.typecons : Nullable;

    Nullable!ImageAnimation animation(string name)
    {
        auto mustBeAnim = animationUnsafe(name);
        return mustBeAnim ? Nullable!ImageAnimation(mustBeAnim) : Nullable!ImageAnimation.init;
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

        if (currentAnimationIndex >= currentAnimation.frameIndices.length - 1)
        {
            if (currentAnimation.onEndFrames)
            {
                currentAnimation.onEndFrames();
            }

            foreach (dg; onEndFrames)
            {
                dg();
            }

            if (!currentAnimation.isLooping)
            {
                stop;
                return;
            }

        }

        auto delay = currentAnimation.frameDelay > 0 ? currentAnimation.frameDelay : frameDelay;

        auto newIndex = ((platform.timer.ticksMs - currentAnimationStartTime) / delay) % animLength;
        if (currentAnimationIndex > 0 && newIndex == 0)
        {
            if (currentAnimation.isLoopRow && currentAnimation.maxFrameRows > 1)
            {
                auto newRow = currentAnimation.frameRow + 1;
                if (newRow >= currentAnimation.maxFrameRows)
                {
                    newRow = 0;
                }
                currentAnimation.frameRow = newRow;
            }
        }

        currentAnimationIndex = newIndex;
    }

    double frameWidthHalf() => frameWidth / 2;
    double frameHeightHalf() => frameHeight / 2;

    override void dispose()
    {
        super.dispose;
        animations = [];
    }
}
