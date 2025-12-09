module api.dm.kit.tweens.min_max_tween;

import api.dm.kit.tweens.tween : Tween, TweenState;
import api.dm.kit.tweens.curves.interpolator : Interpolator;
import api.dm.kit.tweens.curves.uni_interpolator : UniInterpolator;
import api.math.geom2.vec2 : Vec2d;
import math = api.dm.math;

import std.traits : isIntegral, isFloatingPoint;

import std.stdio;

/**
 * Authors: initkfs
 */
class MinMaxTween(T) if (isFloatingPoint!T || is(T : Vec2d)) : Tween
{
    Interpolator interpolator;

    void delegate(T, T)[] onOldNewValue;

    //enum x = 10; tween.onDeltaValue ~= (dv) { sprite.x += x * dv; }
    void delegate(T)[] onDeltaValue;

    T lastValue;

    T _minValue;
    T _maxValue;

    this(T minValue, T maxValue, size_t timeMs = 200, Interpolator interpolator = null)
    {
        super(timeMs);

        this._minValue = minValue;
        this._maxValue = maxValue;

        this.interpolator = interpolator;
        if (!this.interpolator)
        {
            auto uniInterp = new UniInterpolator;
            uniInterp.interpolateMethod = &uniInterp.linear;
            this.interpolator = uniInterp;
        }

        resetLastValue;
    }

    override void stop()
    {
        super.stop;
        resetLastValue;
    }

    protected void resetLastValue()
    {
        static if (isFloatingPoint!T)
        {
            lastValue = 0;
        }
        else
        {
            lastValue = T.init;
        }
    }

    override void onFrame()
    {
        T start;
        T end;
        switch (state)
        {
            case TweenState.direct:
                start = _minValue;
                end = _maxValue;
                break;
            case TweenState.back:
                start = _maxValue;
                end = _minValue;
                break;
            default:
                break;
        }

        float deltaT = currentFrame / frameCount;
        //It’s better to check for isFinite
        float interpProgress = interpolator.interpolate(deltaT);

        import api.math.numericals.interp : lerp;

        auto oldValue = lastValue;

        lastValue = lerp(start, end, interpProgress, false);

        triggerListeners(oldValue, lastValue);
    }

    protected void triggerListeners(T oldValue, T newValue)
    {
        if (onOldNewValue.length > 0)
        {
            foreach (dg; onOldNewValue)
            {
                dg(oldValue, newValue);
            }
        }

        if (onDeltaValue.length > 0)
        {
            const dv = newValue - oldValue;
            foreach (dg; onDeltaValue)
            {
                dg(dv);
            }
        }
    }

    override void update(float delta)
    {
        if (_minValue == _maxValue)
        {
            return;
        }

        super.update(delta);
    }

    T minValue() @safe pure nothrow
    {
        return _minValue;
    }

    void minValue(T newValue, bool isStop = true)
    {
        if (isStop && isRunning)
        {
            //TODO log.
            stop;
        }
        _minValue = newValue;
    }

    T rangeAbs() @safe pure nothrow
    {
        import Math = api.dm.math;

        static if (isFloatingPoint!T)
        {
            return Math.abs(maxValue - minValue);
        }
        else static if (is(T : Vec2d))
        {
            return maxValue.subAbs(minValue);
        }
        else
        {
            static assert(false, "Not supported type for range abs: " ~ T.stringof);
        }
    }

    T maxValue() @safe pure nothrow
    {
        return _maxValue;
    }

    void maxValue(T newValue, bool isStop = true)
    {
        if (isStop && isRunning)
        {
            stop;
            //TODO log
        }
        _maxValue = newValue;
    }

    bool removeOnOldNewValue(void delegate(T, T) dg)
    {
        import api.core.utils.arrays : drop;

        return drop(onOldNewValue, dg);
    }

    override void dispose()
    {
        super.dispose;
        onOldNewValue = null;
    }
}

unittest
{
    import std.conv : to;
    import std.math.operations : isClose;

    enum animationTimeMs = 100;
    auto tr1 = new MinMaxTween!float(0, 10, animationTimeMs);
    tr1.frameRateHz = 60;
    tr1.initialize;
    tr1.create;
    tr1.run;

    import std;

    auto fc = tr1.frameCount(tr1.frameRateHz);
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
                assert(tr1.isStopping);
                assert(isClose(tr1.lastValue, 0, 0.0, eps));
                break;
            default:
                break;
        }
    }
}
