module dm.kit.sprites.transitions.transition;

import dm.kit.sprites.sprite : Sprite;

import std.container.dlist : DList;

enum TransitionState
{
    none,
    direct,
    back,
    end
}

/**
 * Authors: initkfs
 */
abstract class Transition : Sprite
{
    bool isInverse;
    bool isCycle;

    void delegate()[] onEnd;

    double frameRateHz = 0;
    double timeMs = 0;

    protected
    {
        double frameCount = 0;
        long currentFrame;

        bool onShort;

        TransitionState state = TransitionState.none;
        enum firstFrame = 1;

        DList!Transition prevs;
        DList!Transition nexts;
    }

    this(size_t timeMs = 200)
    {
        super();

        import std.conv : to;

        this.timeMs = timeMs.to!double;

        isManaged = false;
        isVisible = false;
        isLayoutManaged = false;
    }

    abstract void onFrame();

    double getFrameRate()
    {
        const double rate = frameRateHz > 0 ? frameRateHz : window.frameRate;
        return rate;
    }

    double getFrameCount(double frameRateHz)
    {
        immutable double frames = (timeMs * frameRateHz) / 1000;
        return frames;
    }

    double getFrameCount()
    {
        return getFrameCount(getFrameRate);
    }

    override void run()
    {
        super.run;

        if (!prevs.empty)
        {
            foreach (prev; prevs)
            {
                assert(prev, "Previous animation must not be null");
                if (prev.isRunning)
                {
                    prev.stop;
                }
            }
        }

        const double rate = getFrameRate;
        //TODO error if <= 0
        if (rate > 0)
        {
            frameCount = getFrameCount(rate);
            currentFrame = firstFrame;
        }
        state = TransitionState.direct;
    }

    override void stop()
    {
        super.stop;

        state = TransitionState.end;

        frameCount = 0;
        currentFrame = 0;

        if (onEnd.length > 0)
        {
            foreach (dg; onEnd)
            {
                dg();
            }
        }

        onShort = false;

        if (!nexts.empty)
        {
            foreach (next; nexts)
            {
                assert(next, "Next animation must not be null");
                if (next.isRunning)
                {
                    next.stop;
                }
                next.run;
            }
        }
    }

    protected bool isRunningState()
    {
        return state == TransitionState.direct || state == TransitionState.back;
    }

    override void update(double delta)
    {
        if (state == TransitionState.none || state == TransitionState.end)
        {
            return;
        }

        super.update(delta);

        if (currentFrame > frameCount)
        {
            if (!isCycle)
            {
                if (!isInverse || onShort)
                {
                    stop;
                    return;
                }
                else
                {
                    onShort = true;
                }
            }

            if (isInverse)
            {
                if (state == TransitionState.direct)
                {
                    state = TransitionState.back;
                }
                else if (state == TransitionState.back)
                {
                    state = TransitionState.direct;
                }
            }
            currentFrame = firstFrame;
        }

        onFrame;

        currentFrame++;
    }

    void prev(Transition newPrev)
    {
        if (!newPrev)
        {
            throw new Exception("Previous transition must not be null");
        }
        prevs ~= newPrev;
    }

    void prev(Transition[] newPrevs...)
    {
        foreach (t; newPrevs)
        {
            prev(t);
        }
    }

    void next(Transition newNext)
    {
        if (!newNext)
        {
            throw new Exception("Next transition must not be null");
        }
        nexts ~= newNext;
    }

    void next(Transition[] newNexts...)
    {
        foreach (t; newNexts)
        {
            next(t);
        }
    }

    override void dispose()
    {
        if (isRunning)
        {
            stop;
        }

        super.dispose;

        prevs.clear;
        nexts.clear;

        onEnd = null;
    }

}
