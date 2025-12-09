module api.dm.gui.controls.meters.radial_min_max_value_meter;

import api.dm.gui.controls.meters.min_max_meter : MinMaxMeter;
import api.dm.kit.graphics.styles.graphic_style: GraphicStyle;
import api.math.geom2.rect2: Rect2f;

/**
 * Authors: initkfs
 */
abstract class RadialMinMaxMeter(ValueType) : MinMaxMeter!ValueType
{
    float minAngleDeg = 0;
    float maxAngleDeg = 0;

    protected
    {
        float _diameter = 0;
        float _radius;
    }

    this(float diameter = 0, ValueType minValue = 0, ValueType maxValue = 1, float minAngleDeg = 0, float maxAngleDeg = 180)
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

    Rect2f handBoundingBox(float handSize){
        return (Rect2f(0, 0, handSize, handSize)).boundingBoxMax;
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

    void diameter(float value)
    {
        _diameter = value;
        _radius = _diameter / 2;
    }

    float diameter() => _diameter;
    float radius() => _radius;
}
