module api.dm.kit.tweens.tween;

import api.dm.kit.components.graphics_component: GraphicsComponent;

import std.container.dlist : DList;

enum TweenState
{
    none,
    pause,
    direct,
    back,
    end
}

/**
 * Authors: initkfs
 */
abstract class Tween : GraphicsComponent
{
    bool isReverse;
    bool isInfinite;
    bool isOneShort;

    size_t cycleCount;

    void delegate()[] onResume;
    void delegate()[] onEnd;

    double frameRateHz = 0;
    double timeMs = 0;

    bool isThrowInvalidTime;

    protected
    {
        double currentFrameCount = 0;
        long currentFrame;
        size_t currentCycle;
        bool currentShort;

        TweenState state = TweenState.none;
        TweenState prevState;

        enum firstFrame = 1;

        DList!Tween prevs;
        DList!Tween nexts;
    }

    this(size_t timeMs = 200)
    {
        super();

        import std.conv : to;

        this.timeMs = timeMs.to!double;
    }

    abstract void onFrame();

    double frameRate()
    {
        const double rate = frameRateHz > 0 ? frameRateHz : window.frameRate;
        return rate;
    }

    double frameCount(double frameRateHz)
    {
        immutable double frames = (timeMs * frameRateHz) / 1000;
        return frames;
    }

    double frameCount()
    {
        return frameCount(frameRate);
    }

    protected bool requestStop()
    {
        return true;
    }

    override void run()
    {
        if (isThrowInvalidTime && timeMs == 0)
        {
            throw new Exception("Animation duration is zero.");
        }

        if (isPaused)
        {
            state = prevState;
            if (isReverse && state == TweenState.direct)
            {
                state = TweenState.back;
            }

            if (onResume.length > 0)
            {
                foreach (dg; onResume)
                {
                    dg();
                }
            }
            super.run;
            return;
        }

        super.run;

        const double rate = frameRate;
        //TODO error if <= 0
        if (rate > 0)
        {
            currentFrameCount = frameCount(rate);
            currentFrame = firstFrame;
        }

        state = !isReverse ? TweenState.direct : TweenState.back;
    }

    override void pause()
    {
        super.pause;

        prevState = state;
        state = TweenState.pause;
    }

    bool isPause()
    {
        return state == TweenState.pause;
    }

    override void stop()
    {
        super.stop;

        state = TweenState.end;

        currentFrameCount = 0;
        currentFrame = 0;
        currentCycle = 0;
        currentShort = false;

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
        return state == TweenState.direct || state == TweenState.back;
    }

    void update(double delta)
    {
        if (!isRunning || !isRunningState)
        {
            return;
        }

        if (currentFrame > currentFrameCount)
        {
            if (onEnd.length > 0)
            {
                foreach (dg; onEnd)
                {
                    dg();
                }
            }

            if (!isInfinite)
            {
                if ((cycleCount == 0 && !isOneShort) || currentShort)
                {
                    if (requestStop)
                    {
                        stop;
                    }
                    return;
                }

                if ((cycleCount > 0 && (currentCycle == (cycleCount - 1))) || currentCycle == currentCycle
                    .max)
                {
                    if (requestStop)
                    {
                        stop;
                    }
                    return;
                }

                currentCycle++;

                if (isOneShort && !currentShort)
                {
                    reverse;
                    currentShort = true;
                }
            }
            else
            {
                if (isReverse)
                {
                    reverse;
                }
            }

            setFirstFrame;
        }

        onFrame;

        currentFrame++;
    }

    void setFirstFrame()
    {
        currentFrame = firstFrame;
    }

    bool isDirect() => state == TweenState.direct;
    bool isBack() => state == TweenState.back;

    void reverse()
    {
        if (state == TweenState.direct)
        {
            state = TweenState.back;
        }
        else if (state == TweenState.back)
        {
            state = TweenState.direct;
        }
    }

    void prev(Tween newPrev)
    {
        if (!newPrev)
        {
            throw new Exception("Previous tween must not be null");
        }

        //TODO remove and clear prevs
        newPrev.onStop ~= () {
            if (!isStopped)
            {
                stop;
            }
            run;
        };

        prevs ~= newPrev;
    }

    void prev(Tween[] newPrevs...)
    {
        foreach (t; newPrevs)
        {
            prev(t);
        }
    }

    void next(Tween newNext)
    {
        if (!newNext)
        {
            throw new Exception("Next tween must not be null");
        }
        nexts ~= newNext;
    }

    void next(Tween[] newNexts...)
    {
        foreach (t; newNexts)
        {
            next(t);
        }
    }

    import api.core.utils.arrays : drop;

    bool removeOnResume(void delegate() dg) => drop(onResume, dg);
    bool removeOnEnd(void delegate() dg) => drop(onEnd, dg);

    override void dispose()
    {
        if (isRunning)
        {
            stop;
        }

        super.dispose;

        prevs.clear;
        nexts.clear;

        onResume = null;
        onEnd = null;
    }
}
