module api.dm.gui.controls.meters.radial_min_value_meter;

import api.dm.gui.controls.meters.min_value_meter : MinValueMeter;

/**
 * Authors: initkfs
 */
abstract class RadialMinValueMeter(ValueType) : MinValueMeter!ValueType
{
    double minAngleDeg = 0;
    double maxAngleDeg = 0;

    protected
    {
        double _diameter = 0;
        double _radius;
    }

    this(double diameter = 0, ValueType minValue = 0, ValueType maxValue = 1, double minAngleDeg = 0, double maxAngleDeg = 180)
    {
        super(minValue, maxValue);

        this._diameter = diameter;
        _radius = _diameter / 2;

        this.minAngleDeg = minAngleDeg;
        this.maxAngleDeg = maxAngleDeg;
    }

    ValueType angleRange()
    {
        import Math = api.math;

        if (minAngleDeg == maxAngleDeg)
        {
            return 0;
        }

        const range = minAngleDeg < maxAngleDeg ? (maxAngleDeg - minAngleDeg) : (
            minAngleDeg - maxAngleDeg);
        return range;
    }

    void diameter(double value)
    {
        _diameter = value;
        _radius = _diameter / 2;
    }

    double diameter() => _diameter;
    double radius() => _radius;
}
