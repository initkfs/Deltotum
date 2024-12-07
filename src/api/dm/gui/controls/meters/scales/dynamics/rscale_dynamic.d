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

        if (_width == 0)
        {
            _width = _diameter * 1.8;
        }

        if (_height == 0)
        {
            _height = _diameter * 1.8;
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

    override Vec2d tickStep(size_t i, double startX, double startY, double tickOffset)
    {
        return boundsRect.center.add(Vec2d.fromPolarDeg((i + 1) * (tickOffset), radius));
    }

    override void drawTick(size_t i, double startX, double startY, double w, double h, RGBA color)
    {
        const start = Vec2d(startX, startY);
        const end = Vec2d.fromPolarDeg(i * tickOffset, h);
        graphics.line(start.x, start.y, start.x + end.x, start.y + end.y, color);
    }

    override Vec2d labelPos(size_t i, double startX, double startY, Text label, double tickWidth, double tickHeight)
    {
        const pos = Vec2d.fromPolarDeg(i * tickOffset, tickMajorHeight).add(Vec2d(startX, startY));
        return pos;
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
