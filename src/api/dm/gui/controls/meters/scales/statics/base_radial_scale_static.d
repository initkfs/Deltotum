module api.dm.gui.controls.meters.scales.statics.base_radial_scale_static;

import api.dm.gui.controls.meters.scales.base_minmax_scale : BaseMinMaxScale;
import api.dm.kit.sprites.sprites2d.textures.texture2d : Texture2d;
import api.math.geom2.vec2 : Vec2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.geom2.rect2 : Rect2d;
import Math = api.math;

/**
 * Authors: initkfs
 */
class BaseRadialScaleStatic : BaseMinMaxScale
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

        import api.dm.kit.sprites.sprites2d.textures.vectors.vector_texture : VectorTexture;
        import api.dm.kit.sprites.sprites2d.textures.rgba_texture : RgbaTexture;
        import api.dm.kit.sprites.sprites2d.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

        auto smallTickProto = new VConvexPolygon(tickMinorHeight, tickMinorWidth, GraphicStyle(0, theme.colorAccent, true, theme
                .colorAccent), 0);
        build(smallTickProto);
        smallTickProto.initialize;
        smallTickProto.create;
        smallTickProto.bestScaleMode;

        auto bigTickProto = new VConvexPolygon(tickMajorHeight, tickMajorWidth, GraphicStyle(2, theme.colorDanger, true, theme
                .colorDanger), 0);
        build(bigTickProto);
        bigTickProto.initialize;
        bigTickProto.create;
        bigTickProto.bestScaleMode;

        import api.dm.gui.controls.texts.text : Text;
        import api.dm.kit.assets.fonts.font_size : FontSize;

        import std.conv : to;

        auto labelProto = new Text("!");
        build(labelProto);
        labelProto.fontSize = FontSize.small;
        labelProto.initialize;
        labelProto.create;

        scope (exit)
        {
            smallTickProto.dispose;
            bigTickProto.dispose;
            labelProto.dispose;
        }

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
                bestScaleMode;

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

                    Texture2d proto = (majorTickStep > 0 && ((i % majorTickStep) == 0)) ? bigTickProto
                        : smallTickProto;

                    proto.angle = startAngleDeg;

                    if (i == endIndex)
                    {
                        proto.angle = maxAngleDeg;
                    }

                    auto tickX = center.x + pos.x - proto.boundsRect.halfWidth;
                    auto tickY = center.y + pos.y - proto.boundsRect.halfHeight;

                    auto tickBoundsW = proto.width;
                    auto tickBoundsH = proto.height;

                    copyFrom(proto, Rect2d(0, 0, proto.width, proto.height), Rect2d(tickX, tickY, tickBoundsW, tickBoundsH));

                    if ((isShowFirstLastLabel && (i == 0 || i == endIndex)) || (labelStep > 0 && (
                            i % labelStep == 0)))
                    {

                        auto labelText = (i * valueStep).to!dstring;
                        labelProto.text = labelText;
                        labelProto.updateRows(isForce : true);

                        const labelProtoBounds = labelProto.boundsRect;

                        auto textPos = Vec2d.fromPolarDeg(startAngleDeg, radius + tickBoundsW);

                        auto textX = center.x + textPos.x- labelProto.boundsRect.halfWidth;
                        auto textY = center.y + textPos.y - labelProto.boundsRect.halfHeight;

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
