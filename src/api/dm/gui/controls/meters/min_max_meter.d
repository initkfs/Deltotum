module api.dm.gui.controls.meters.min_max_meter;

import api.dm.gui.controls.control : Control;

/**
 * Authors: initkfs
 */
abstract class MinMaxMeter(ValueType) : Control
{
    ValueType minValue;
    ValueType maxValue;

    this(ValueType minValue, ValueType maxValue)
    {
        this.minValue = minValue;
        this.maxValue = maxValue;
    }

    ValueType valueRange()
    {
        import Math = api.math;

        if (minValue == maxValue)
        {
            return 0;
        }

        const ValueType range = minValue < maxValue ? (maxValue - minValue) : (minValue - maxValue);
        return range;
    }
}
