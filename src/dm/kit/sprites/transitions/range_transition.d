module dm.kit.sprites.transitions.range_transition;

import dm.kit.sprites.transitions.transition;
import dm.math.vector2 : Vector2;

import Math = dm.math;

import std.traits : isIntegral, isFloatingPoint;

/**
 * Authors: initkfs
 */
class RangeTransition(T) : Transition
{
    T[] range;
    size_t rangePositionStart;
    size_t rangeIncreaseValue;

    void delegate(T[]) onValueSlice;

    this(size_t timeMs = 200)
    {
        super(timeMs);
    }

    override void run()
    {
        super.run;

        import std.conv : to;
        import std.math.rounding : ceil;

        rangeIncreaseValue = (ceil(range.length / frameCount)).to!size_t;
    }

    override void stop()
    {
        super.stop;
        rangePositionStart = 0;
        rangeIncreaseValue = 0;
    }

    override void onFrame()
    {
        if (rangeIncreaseValue == 0 && range.length == 0)
        {
            return;
        }

        auto endPosition = rangePositionStart + rangeIncreaseValue;
        if (endPosition >= range.length)
        {
            auto rest = range[rangePositionStart .. $];
            if (onValueSlice)
            {
                onValueSlice(rest);
            }
            rangePositionStart += rest.length;
            stop;
            return;
        }

        auto slice = range[rangePositionStart .. endPosition];
        if (onValueSlice)
        {
            onValueSlice(slice);
        }
        rangePositionStart = endPosition;
    }
}
