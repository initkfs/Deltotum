module api.dm.kit.sprites.sprites2d.tweens.min_max_tween2d;

import api.dm.kit.sprites.sprites2d.tweens.tween2d : Tween2d;
import api.dm.kit.tweens.min_max_tween : MinMaxTween;
import api.dm.kit.tweens.curves.interpolator : Interpolator;
import api.math.geom2.vec2 : Vec2d;
import std.traits : isIntegral, isFloatingPoint;

import std.stdio;

/**
 * Authors: initkfs
 */
class MinMaxTween2d(T) if (isFloatingPoint!T || is(T : Vec2d)) : Tween2d
{
    ref void delegate(T, T)[] onOldNewValue() => mTween.onOldNewValue;

    protected
    {
        MinMaxTween!T mTween;
    }

    this(T minValue, T maxValue, size_t timeMs = 200, Interpolator interpolator = null)
    {
        super(new MinMaxTween!T(minValue, maxValue, timeMs, interpolator));

        this.mTween = cast(MinMaxTween!T) tween;
    }

    T minValue() @safe pure nothrow => mTween.minValue;
    void minValue(T newValue, bool isStop = true)
    {
        mTween.minValue(newValue, isStop);
        if(isStop && isRunning && !mTween.isRunning){
            super.stop;
        }
    }

    T maxValue() @safe pure nothrow => mTween.maxValue;
    void maxValue(T newValue, bool isStop = true)
    {
        mTween.maxValue(newValue, isStop);
        if(isStop && isRunning && !mTween.isRunning){
            super.stop;
        }
    }

    Interpolator interpolator() => mTween.interpolator;
    void interpolator(Interpolator interp)
    {
        mTween.interpolator = interp;
    }

    bool removeOnOldNewValue(void delegate(T, T) dg) => mTween.removeOnOldNewValue(dg);

    override void dispose()
    {
        super.dispose;
    }
}
