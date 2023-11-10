module deltotum.kit.sprites.animations.transition;

import deltotum.kit.sprites.animations.animation : Animation;
import deltotum.kit.sprites.animations.interp.interpolator : Interpolator;
import deltotum.kit.sprites.animations.interp.uni_interpolator : UniInterpolator;
import deltotum.math.vector2d : Vector2d;
import math = deltotum.math;

import std.traits : isIntegral, isFloatingPoint;

import std.stdio;

private
{
    enum TransitionState
    {
        none,
        direct,
        back,
        end
    }
}

/**
 * Authors: initkfs
 */
class Transition(T) if (isFloatingPoint!T || is(T : Vector2d)) : Animation
{
    void delegate(T) onValue;

    Interpolator interpolator;

    T lastValue;

    T _minValue;
    T _maxValue;

    double frameRateHz = 0;

    private
    {
        double timeMs = 0;
        double frameCount = 0;
        long currentFrame;

        bool onShort;

        TransitionState state = TransitionState.none;
        enum firstFrame = 1;
    }

    this(T minValue, T maxValue, size_t timeMs = 200, Interpolator interpolator = null)
    {
        super();
        this._minValue = minValue;
        this._maxValue = maxValue;

        import std.conv : to;

        this.timeMs = timeMs.to!double;

        this.interpolator = interpolator;
        if (!this.interpolator)
        {
            auto uniInterp = new UniInterpolator;
            uniInterp.interpolateMethod = &uniInterp.linear;
            this.interpolator = uniInterp;
        }
        isManaged = false;
        isVisible = false;
    }

    override void run()
    {
        super.run;

        const double frameRate = frameRateHz > 0 ? frameRateHz : window.frameRate;
        //TODO error if <= 0
        if (frameRate > 0)
        {
            frameCount = getFrameCount(frameRate);
            currentFrame = firstFrame;
        }
        state = TransitionState.direct;
    }

    double getFrameCount(double frameRateHz)
    {
        immutable double frames = (timeMs * frameRateHz) / 1000;
        return frames;
    }

    //TODO state management
    override void stop()
    {
        super.stop;

        state = TransitionState.end;
        frameCount = 0;
        currentFrame = 0;

        import std.traits : isFloatingPoint;

        static if (isFloatingPoint!T)
        {
            lastValue = 0;
        }
        else
        {
            lastValue = T.init;
        }
        onShort = false;
    }

    override void update(double delta)
    {
        if (state == TransitionState.none || state == TransitionState.end)
        {
            return;
        }

        if (_minValue == _maxValue)
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
                    if (onEnd)
                    {
                        onEnd();
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

        T start;
        T end;
        switch (state)
        {
            case TransitionState.direct:
                start = _minValue;
                end = _maxValue;
                break;
            case TransitionState.back:
                start = _maxValue;
                end = _minValue;
                break;
            default:
                break;
        }

        double deltaT = currentFrame / frameCount;
        //It’s better to check for isFinite
        double interpProgress = interpolator.interpolate(deltaT);

        import deltotum.math.numericals.interp : lerp;

        lastValue = lerp(start, end, interpProgress, false);

        if (onValue)
        {
            onValue(lastValue);
        }

        currentFrame++;
    }

    T minValue() @nogc @safe pure nothrow
    {
        return _minValue;
    }

    void minValue(T newValue)
    {
        if (isRunning)
        {
            //TODO log.
            stop;
        }
        _minValue = newValue;
    }

    T maxValue() @nogc @safe pure nothrow
    {
        return _maxValue;
    }

    void maxValue(T newValue)
    {
        if (isRunning)
        {
            stop;
            //TODO log
        }
        _maxValue = newValue;
    }

    override void dispose()
    {
        if (isRunning)
        {
            stop;
        }
        super.dispose;
    }

}

unittest
{
    import std.conv : to;
    import std.math.operations : isClose;

    enum animationTimeMs = 100;
    auto tr1 = new Transition!double(0, 10, animationTimeMs);
    tr1.frameRateHz = 60;
    tr1.initialize;
    tr1.create;
    tr1.run;

    import std;

    auto fc = tr1.getFrameCount(tr1.frameRateHz);
    enum frameCount = 6;
    assert(fc.to!int == frameCount);
    enum eps = 0.001;
    foreach (i; 0 .. frameCount + 1)
    {
        tr1.update(0);
        switch (i)
        {
            case 0:
                assert(isClose(tr1.lastValue, 1.666, 0.0, eps));
                break;
            case 1:
                assert(isClose(tr1.lastValue, 3.333, 0.0, eps));
                break;
            case 2:
                assert(isClose(tr1.lastValue, 5, 0.0, eps));
                break;
            case 3:
                assert(isClose(tr1.lastValue, 6.666, 0.0, eps));
                break;
            case 4:
                assert(isClose(tr1.lastValue, 8.333, 0.0, eps));
                break;
            case 5:
                assert(isClose(tr1.lastValue, 10, 0.0, eps));
                break;
            case 6:
                //Frame after animation stops
                assert(isClose(tr1.lastValue, 0, 0.0, eps));
                break;
            default:
                break;
        }
    }
}
