module api.dm.gui.controls.meters.radial_min_max_value_meter;

import api.dm.gui.controls.meters.min_max_value_meter : MinMaxValueMeter;
import api.dm.kit.graphics.styles.graphic_style: GraphicStyle;
import api.math.geom2.rect2: Rect2d;

/**
 * Authors: initkfs
 */
abstract class RadialMinMaxValueMeter(ValueType) : MinMaxValueMeter!ValueType
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

    GraphicStyle createHandStyle(){
        auto handStyle = createFillStyle;
        if (!handStyle.isPreset)
        {
            handStyle.fillColor = theme.colorDanger;
            handStyle.lineColor = theme.colorAccent;
        }
        return handStyle;
    }

    Rect2d handBoundingBox(double handSize){
        return (Rect2d(0, 0, handSize, handSize)).boundingBoxMax;
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
