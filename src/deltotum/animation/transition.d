module deltotum.animation.transition;

import deltotum.display.display_object : DisplayObject;
import deltotum.animation.interp.interpolator : Interpolator;
import deltotum.animation.interp.uni_interpolator : UniInterpolator;
import deltotum.math.vector2d : Vector2d;
import deltotum.math.math : Math;

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
class Transition(T) if (isIntegral!T || isFloatingPoint!T || is(T : Vector2d)) : DisplayObject
{
    @property void delegate(T) onValue;
    @property bool isInverse;
    @property bool isCycle = true;
    @property Interpolator interpolator;
    @property T lastValue;

    private
    {
        double timeMs = 0;
        double frameCount = 0;
        long currentFrame;
        T minValue;
        T maxValue;
        bool onShort;

        TransitionState state = TransitionState.none;
    }

    this(T minValue, T maxValue, int timeMs = 200, Interpolator interpolator = null)
    {
        super();
        this.minValue = minValue;
        this.maxValue = maxValue;
        this.timeMs = timeMs;
        this.interpolator = interpolator;
        if (this.interpolator is null)
        {
            auto uniInterp = new UniInterpolator;
            uniInterp.interpolateMethod = &uniInterp.linear;
            this.interpolator = uniInterp;
        }
    }

    void run() @nogc nothrow @safe
    {
        const double frameRateHz = window.frameRate;
        //TODO error if <= 0
        if (frameRateHz > 0)
        {
            frameCount = (timeMs * frameRateHz) / 1000;
        }
        state = TransitionState.direct;
    }

    bool isRun() @nogc nothrow @safe
    {
        return state != TransitionState.end && state != TransitionState.none;
    }

    void stop() @nogc nothrow @safe
    {
        state = TransitionState.end;
        frameCount = 0;
        currentFrame = 0;
        onShort = false;
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

            if (state == TransitionState.direct)
            {
                state = TransitionState.back;
            }
            else if (state == TransitionState.back)
            {
                state = TransitionState.direct;
            }
            currentFrame = 0;
        }

        T start;
        T end;
        switch (state)
        {
        case TransitionState.direct:
            start = minValue;
            end = maxValue;
            break;
        case TransitionState.back:
            start = maxValue;
            end = minValue;
            break;
        default:
            break;
        }

        double deltaT = currentFrame / frameCount;
        //TODO check is finite
        double interpProgress = interpolator.interpolate(deltaT);
        lastValue = Math.lerp(start, end, interpProgress, false);

        if (onValue !is null)
        {
            onValue(lastValue);
        }

        currentFrame++;
    }
}
