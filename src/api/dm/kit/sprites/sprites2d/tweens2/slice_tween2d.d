module api.dm.kit.sprites.sprites2d.tweens2.slice_tween2d;

import api.dm.kit.sprites.sprites2d.tweens2.min_max_tween2d : MinMaxTween2d;
import api.dm.kit.tweens.curves.interpolator : Interpolator;
import api.math.geom2.vec2 : Vec2d;

import Math = api.dm.math;

import std.traits : isIntegral, isFloatingPoint;

/**
 * Authors: initkfs
 */
class SliceTween2d(T) : MinMaxTween2d!double
{
    T[] range;

    protected
    {
        size_t rangePositionStart;
        size_t rangePositionEnd;
    }

    invariant
    {
        assert(rangePositionStart <= rangePositionEnd, "The star index must be less than or equal to the end index");
    }

    void delegate(T[]) onValueSlice;

    this(size_t timeMs = 200, Interpolator interpolator = null)
    {
        super(0, 1, timeMs, interpolator);
    }

    override void initialize()
    {
        super.initialize;

        onOldNewValue ~= (oldValue, newValue) {
            if (range.length == 0)
            {
                return;
            }

            auto currCount = cast(size_t)(range.length * newValue);
            size_t sliceCount = currCount - rangePositionStart;

            if (sliceCount == 0)
            {
                return;
            }

            auto newEnd = rangePositionStart + sliceCount;

            // import std;

            // writeln(currCount, " count: ", sliceCount, " ", rangePositionStart, "...", rangePositionEnd, " len", range
            //         .length, " end ", newEnd, "v ", newValue);

            if (newEnd > range.length)
            {
                rangePositionEnd = range.length;
                callOnSlice;
                stop;
                return;
            }
            else if (newValue == maxValue)
            {
                rangePositionEnd = range.length;
                callOnSlice;
                return;
            }

            rangePositionEnd = newEnd;
            callOnSlice;
            rangePositionStart = rangePositionEnd;
        };
    }

    protected void callOnSlice()
    {
        auto slice = range[rangePositionStart .. rangePositionEnd];
        callOnSlice(slice);
    }

    protected void callOnSlice(T[] slice)
    {
        if (onValueSlice && slice.length > 0)
        {
            onValueSlice(slice);
        }
    }

    override void stop()
    {
        super.stop;

        import std;

        if (range.length > 0 && rangePositionEnd < range.length)
        {
            auto rest = range[rangePositionEnd .. $];
            callOnSlice(rest);
        }

        rangePositionStart = 0;
        rangePositionEnd = 0;
    }
}
