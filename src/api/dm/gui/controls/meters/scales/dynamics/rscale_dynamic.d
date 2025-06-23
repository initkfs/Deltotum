module api.dm.gui.controls.meters.scales.dynamics.rscale_dynamic;

import api.dm.gui.controls.meters.scales.dynamics.base_scale_dynamic : BaseScaleDynamic;
import api.math.geom2.vec2 : Vec2d;
import api.math.geom2.rect2 : Rect2d;
import api.dm.gui.controls.texts.text : Text;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.geom2.line2 : Line2d;

import Math = api.math;

/**
 * Authors: initkfs
 */
class RScaleDynamic : BaseScaleDynamic
{
    double minAngleDeg = 0;
    double maxAngleDeg = 0;

    protected
    {
        double _diameter = 0;
        double radius = 0;
    }

    this(double diameter = 0, double minAngleDeg = 0, double maxAngleDeg = 90)
    {
        super(diameter, diameter);

        this.minAngleDeg = minAngleDeg;
        this.maxAngleDeg = maxAngleDeg;

        this._diameter = diameter;

        isDrawAxis = false;
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadRScaleDynamicSizeTheme;
    }

    void loadRScaleDynamicSizeTheme()
    {
        if (_diameter == 0)
        {
            _diameter = theme.meterThumbDiameter;
        }

        if (width == 0)
        {
            initWidth = _diameter * 1.8;
        }

        if (height == 0)
        {
            initHeight = _diameter * 1.8;
        }
    }

    override void initialize()
    {
        super.initialize;

        radius = (_diameter * 0.7) / 2;

    }

    override void createLabelPool()
    {
        super.createLabelPool;
    }

    override double tickOffset()
    {
        const angleRange = Math.abs(maxAngleDeg - minAngleDeg);
        const angleDegDiff = angleRange / (tickCount - 1);
        return angleDegDiff;
    }

    override Vec2d tickStep(size_t i, Vec2d startPos, double tickOffset)
    {
        return boundsRect.center.add(Vec2d.fromPolarDeg((i + 1) * (tickOffset), radius));
    }

    override bool drawTick(size_t i, Vec2d pos, bool isMajorTick, double offsetTick)
    {
        auto tickW = isMajorTick ? tickMajorWidth : tickMinorWidth;
        auto tickH = isMajorTick ? tickMajorHeight : tickMinorHeight;

        auto tickX = pos.x - tickW / 2;
        auto tickY = pos.y - tickH / 2;

        auto tickColor = isMajorTick ? theme.colorDanger : theme.colorAccent;

        const end = pos.add(Vec2d.fromPolarDeg(i * tickOffset, tickH));
        graphic.line(pos, end, tickColor);
        return true;
    }

    override bool drawLabel(size_t labelIndex, size_t tickIndex, Vec2d pos, bool isMajorTick, double offsetTick)
    {
        if (!isMajorTick || labelIndex >= labels.length)
        {
            return false;
        }

        auto label = labels[labelIndex];
        
        auto tickH = tickMajorHeight;

        const labelPos = pos.add(Vec2d.fromPolarDeg(tickIndex * tickOffset, tickH));
        label.xy(labelPos);
        showLabelIsNeed(labelIndex, label);
        return true;
    }

    override Line2d axisPos()
    {
        const bounds = boundsRect;
        const start = Vec2d(bounds.middleX, bounds.y);
        const end = Vec2d(bounds.middleX, bounds.bottom);
        return Line2d(start, end);
    }

    override Vec2d tickStartPos()
    {
        const bounds = boundsRect;
        return Vec2d.fromPolarDeg(minAngleDeg, radius).add(bounds.center);
    }
}
