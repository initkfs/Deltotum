module dm.kit.sprites.transitions.transition;

import dm.kit.sprites.sprite : Sprite;

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
    bool isInverse;
    bool isCycle;

    void delegate()[] onRun;
    void delegate()[] onStop;
    void delegate()[] onPause;
    void delegate()[] onResume;

    double frameRateHz = 0;
    double timeMs = 0;

    protected
    {
        double frameCount = 0;
        long currentFrame;

        bool onShort;

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

    protected bool requestStop()
    {
        return true;
    }

    override void run()
    {
        if (isPause)
        {
            resume;
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

        const double rate = getFrameRate;
        //TODO error if <= 0
        if (rate > 0)
        {
            frameCount = getFrameCount(rate);
            currentFrame = firstFrame;
        }
        state = TransitionState.direct;
    }

    void resume()
    {
        if (!isPause)
        {
            return;
        }

        state = prevState;

        if (onResume.length > 0)
        {
            foreach (dg; onResume)
            {
                dg();
            }
        }
    }

    void pause()
    {
        if (!isRunningState)
        {
            return;
        }

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

        frameCount = 0;
        currentFrame = 0;
        onShort = false;

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
        if (!isRunningState)
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
                    if (requestStop)
                    {
                        stop;
                    }
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
    }

}
