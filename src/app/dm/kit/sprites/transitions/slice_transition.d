module app.dm.kit.sprites.transitions.slice_transition;

import app.dm.kit.sprites.transitions.min_max_transition : MinMaxTransition;
import app.dm.math.interps.interpolator : Interpolator;
import app.dm.math.vector2 : Vector2;

import Math = app.dm.math;

import std.traits : isIntegral, isFloatingPoint;

/**
 * Authors: initkfs
 */
class SliceTransition(T) : MinMaxTransition!double
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

        import std.math.rounding : ceil;

        onOldNewValue ~= (oldValue, newValue) {
            auto delta = Math.abs(newValue - oldValue);
            auto sliceCount = cast(size_t) ceil(range.length * delta);
            auto newEnd = rangePositionStart + sliceCount;
            if (newEnd > range.length)
            {
                rangePositionEnd = range.length;
                callOnSlice;
                stop;
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
