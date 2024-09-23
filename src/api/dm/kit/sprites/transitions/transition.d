module api.dm.kit.sprites.transitions.transition;

import api.dm.kit.sprites.sprite : Sprite;

import std.container.dlist : DList;

enum TransitionState
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
abstract class Transition : Sprite
{
    bool isReverse;
    bool isInfinite;
    bool isOneShort;

    size_t cycleCount;

    void delegate()[] onRun;
    void delegate()[] onStop;
    void delegate()[] onPause;
    void delegate()[] onResume;
    void delegate()[] onEnd;

    double frameRateHz = 0;
    double timeMs = 0;

    protected
    {
        double currentFrameCount = 0;
        long currentFrame;
        size_t currentCycle;
        bool currentShort;

        TransitionState state = TransitionState.none;
        TransitionState prevState;

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
        isManagedByScene = true;
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
        if (isPaused)
        {
            state = prevState;

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

        if (onRun.length > 0)
        {
            foreach (dg; onRun)
            {
                dg();
            }
        }

        const double rate = frameRate;
        //TODO error if <= 0
        if (rate > 0)
        {
            currentFrameCount = frameCount(rate);
            currentFrame = firstFrame;
        }
        state = TransitionState.direct;
    }

    override void pause()
    {
        super.pause;

        prevState = state;
        state = TransitionState.pause;

        if (onPause.length > 0)
        {
            foreach (dg; onPause)
            {
                dg();
            }
        }
    }

    bool isPause()
    {
        return state == TransitionState.pause;
    }

    override void stop()
    {
        super.stop;

        state = TransitionState.end;

        currentFrameCount = 0;
        currentFrame = 0;
        currentCycle = 0;
        currentShort = false;

        if (onStop.length > 0)
        {
            foreach (dg; onStop)
            {
                dg();
            }
        }

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
        if (!isRunning || !isRunningState)
        {
            return;
        }

        super.update(delta);

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

    void reverse()
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

    void prev(Transition newPrev)
    {
        if (!newPrev)
        {
            throw new Exception("Previous transition must not be null");
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

    import api.core.utils.arrays: drop;

    bool removeOnRun(void delegate() dg) => drop(onRun, dg);
    bool removeOnStop(void delegate() dg) => drop(onStop, dg);
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

        onStop = null;
        onRun = null;
        onPause = null;
        onResume = null;
        onEnd = null;
    }

}
