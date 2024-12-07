module api.dm.gui.controls.meters.scales.statics.base_radial_scale_static;

import api.dm.gui.controls.meters.scales.statics.base_scale_static : BaseScaleStatic;
import api.dm.kit.sprites.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.sprites.sprites2d.textures.rgba_texture : RgbaTexture;
import api.math.geom2.vec2 : Vec2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.geom2.rect2 : Rect2d;
import Math = api.math;

import std.conv: to;

/**
 * Authors: initkfs
 */
class BaseRadialScaleStatic : BaseScaleStatic
{
    double minAngleDeg = 0;
    double maxAngleDeg = 0;

    size_t labelStep = 5;

    double _diameter = 0;

    this(double diameter, double minAngleDeg = 0, double maxAngleDeg = 360)
    {
        this._diameter = diameter;

        this.minAngleDeg = minAngleDeg;
        this.maxAngleDeg = maxAngleDeg;
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
    }

    override void create()
    {
        super.create;

        const centerShapeW = width;
        const centerShapeH = height;

        auto centerShape = new class RgbaTexture
        {
            this()
            {
                super(centerShapeW, centerShapeH);
            }

            override void createTextureContent()
            {
                auto radius = _diameter / 2;

                Vec2d center = Vec2d(width / 2, height / 2);

                auto valueRange = range;

                auto startAngleDeg = minAngleDeg;
                auto endAngleDeg = maxAngleDeg;

                double angleRange = Math.abs(endAngleDeg - startAngleDeg);

                auto ticksCount = tickCount;

                double angleDegDiff = angleRange / (ticksCount - 1);

                size_t endIndex = ticksCount - 1;
                assert(endIndex < ticksCount);
                foreach (i; 0 .. ticksCount)
                {
                    auto pos = Vec2d.fromPolarDeg(startAngleDeg, radius);

                    auto proto = (majorTickStep > 0 && ((i % majorTickStep) == 0)) ? majorTickProto
                        : minorTickProto;

                    proto.angle = startAngleDeg;

                    if (i == endIndex)
                    {
                        proto.angle = maxAngleDeg;
                    }

                    proto.angle = (proto.angle + 90) % 360;

                    auto tickX = center.x + pos.x - proto.boundsRect.halfWidth;
                    auto tickY = center.y + pos.y - proto.boundsRect.halfHeight;

                    auto tickBoundsW = proto.height;
                    auto tickBoundsH = proto.width;

                    // copyFrom(proto, Rect2d(0, 0, proto.width, proto.height), Rect2d(tickX, tickY, tickBoundsW, tickBoundsH));
                    proto.xy(tickX, tickY);

                    proto.draw;

                    if ((isShowFirstLastLabel && (i == 0 || i == endIndex)) || (labelStep > 0 && (
                            i % labelStep == 0)))
                    {

                        auto labelText = (i * valueStep).to!dstring;
                        labelProto.text = labelText;
                        labelProto.updateRows(isForce : true);

                        const labelProtoBounds = labelProto.boundsRect;

                        auto textPos = Vec2d.fromPolarDeg(startAngleDeg, radius + tickBoundsW);

                        auto textX = center.x + textPos.x - labelProto.boundsRect.halfHeight;
                        auto textY = center.y + textPos.y - labelProto.boundsRect.halfWidth;

                        double nextX = textX;

                        labelProto.onFontTexture((fontTexture, const glyphPtr) {

                            Rect2d textDest =
                            {
                                nextX, textY, glyphPtr.geometry.width, glyphPtr.geometry.height
                            };

                            copyFrom(fontTexture, glyphPtr.geometry, textDest);
                            nextX += glyphPtr.geometry.width;
                            return true;
                        });
                    }

                    startAngleDeg = (startAngleDeg + angleDegDiff) % 360;
                }
            }
        };

        addCreate(centerShape);
    }
}
