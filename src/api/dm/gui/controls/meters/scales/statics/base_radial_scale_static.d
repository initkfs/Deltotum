module api.dm.gui.controls.meters.scales.statics.base_radial_scale_static;

import api.dm.gui.controls.meters.scales.statics.base_scale_static : BaseScaleStatic;
import api.dm.kit.sprites.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.sprites.sprites2d.textures.rgba_texture : RgbaTexture;
import api.math.geom2.vec2 : Vec2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.texts.text : Text;
import api.math.geom2.rect2 : Rect2d;
import api.math.geom2.line2 : Line2d;
import Math = api.math;

import std.conv : to;

/**
 * Authors: initkfs
 */
class BaseRadialScaleStatic : BaseScaleStatic
{
    double minAngleDeg = 0;
    double maxAngleDeg = 0;

    size_t labelStep = 5;

    double _diameter = 0;

    Texture2d scaleShape;

    protected
    {
        double radius = 0;
    }

    this(double diameter, double minAngleDeg = 0, double maxAngleDeg = 360)
    {
        this._diameter = diameter;

        this.minAngleDeg = minAngleDeg;
        this.maxAngleDeg = maxAngleDeg;

        isDrawAxis = false;
    }

    override void loadTheme()
    {
        super.loadTheme;

        if (_diameter == 0)
        {
            _diameter = theme.meterThumbDiameter * 2;
        }

        assert(_diameter);

        if (_width == 0)
        {
            _width = _diameter * 1.8;
        }

        if (_height == 0)
        {
            _height = _diameter * 1.8;
        }

        radius = _diameter / 2;
    }

    override void create()
    {
        super.create;

        scaleShape = new Texture2d(width, height);
        buildInitCreate(scaleShape);

        scaleShape.createTargetRGBA32;
        scaleShape.blendModeBlend;

        scaleShape.setRendererTarget;
        scope (exit)
        {
            scaleShape.restoreRendererTarget;
        }

        graphics.clearTransparent;

        drawScale;

        addCreate(scaleShape);
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

    override double tickOffset()
    {
        const angleRange = Math.abs(maxAngleDeg - minAngleDeg);
        const angleDegDiff = angleRange / (tickCount - 1);
        return angleDegDiff;
    }

    override Vec2d tickStep(size_t i, Vec2d pos, double offsetTick)
    {
        return scaleShape.boundsRect.center.add(Vec2d.fromPolarDeg((i + 1) * (tickOffset), radius));
    }

    override bool drawTick(size_t i, Vec2d pos, bool isMajorTick, double offsetTick)
    {
        auto proto = isMajorTick ? majorTickProto : minorTickProto;

        auto tickX = pos.x - proto.boundsRect.halfWidth;
        auto tickY = pos.y - proto.boundsRect.halfHeight;

        proto.xy = Vec2d(tickX, tickY);

        proto.angle = i * tickOffset;
        proto.angle = (proto.angle + 90) % 360;

        proto.draw;
        return true;
    }

    override bool drawLabel(size_t labelIndex, size_t tickIndex, Vec2d pos, bool isMajorTick, double offsetTick)
    {
        if (!isMajorTick)
        {
            return false;
        }

        const center = scaleShape.boundsRect.center;

        import std.conv : to;

        auto labelText = (tickIndex * valueStep).to!dstring;
        labelProto.text = labelText;
        labelProto.updateRows(isForce : true);

        const tickBoundsW = majorTickProto.boundsRect.height;

        auto textPos = Vec2d.fromPolarDeg(tickIndex * offsetTick, radius + tickBoundsW);

        auto textX = center.x + textPos.x - labelProto.boundsRect.halfHeight;
        auto textY = center.y + textPos.y - labelProto.boundsRect.halfWidth;

        double nextX = textX;

        labelProto.onFontTexture((fontTexture, const glyphPtr) {

            Rect2d textDest =
            {nextX, textY, glyphPtr.geometry.width, glyphPtr.geometry.height};

            scaleShape.copyFrom(fontTexture, glyphPtr.geometry, textDest);
            nextX += glyphPtr.geometry.width;
            return true;
        });
        return true;
    }
}
