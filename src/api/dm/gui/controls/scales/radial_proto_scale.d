module api.dm.gui.controls.scales.radial_proto_scale;

import api.dm.gui.controls.control : Control;
import api.math.geom2.vec2 : Vec2d;
import api.math.geom2.rect2 : Rect2d;
import Math = api.math;

/**
 * Authors: initkfs
 */
class RadialProtoScale : Control
{
    double minAngleDeg = 0;
    double maxAngleDeg = 0;

    double minValue = 0;
    double maxValue = 1;
    double valueStep = 0.05;
    size_t majorTickStep = 5;
    size_t labelStep = 5;
    
    bool isShowFirstLastLabel = true;

    double _diameter = 0;

    size_t tickWidth = 2;
    size_t tickHeight = 6;
    size_t tickMajorWidth = 2;
    size_t tickMajorHeight = 12;

    size_t tickOuterPadding = 10;
    size_t labelOuterPadding = 2;

    this(double diameter = 50, double minAngleDeg = 0, double maxAngleDeg = 360)
    {
        this._diameter = diameter;
        assert(_diameter > 0);

        this._width = diameter;
        this._height = diameter;

        this.minAngleDeg = minAngleDeg;
        this.maxAngleDeg = maxAngleDeg;

        import api.dm.kit.sprites.layouts.center_layout : CenterLayout;

        this.layout = new CenterLayout;
    }

    override void create()
    {
        super.create;

        import api.dm.kit.sprites.textures.vectors.vector_texture : VectorTexture;
        import api.dm.kit.sprites.textures.rgba_texture : RgbaTexture;
        import api.dm.kit.sprites.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

        auto smallTickProto = new VConvexPolygon(tickHeight, tickWidth, GraphicStyle(0, graphics.theme.colorAccent, true, graphics
                .theme.colorAccent), 0);
        build(smallTickProto);
        smallTickProto.initialize;
        smallTickProto.create;
        smallTickProto.bestScaleMode;

        auto bigTickProto = new VConvexPolygon(tickMajorHeight, tickMajorWidth, GraphicStyle(2, graphics
                .theme.colorDanger, true, graphics
                .theme.colorDanger), 0);
        build(bigTickProto);
        bigTickProto.initialize;
        bigTickProto.create;
        bigTickProto.bestScaleMode;

        import api.dm.gui.controls.texts.text : Text;
        import api.dm.kit.assets.fonts.font_size : FontSize;
        import api.dm.kit.sprites.textures.texture : Texture;

        import std.conv: to;

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

        size_t ticksCount = ((Math.abs(maxValue - minValue)) / valueStep).to!size_t;

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

                auto valueRange = maxValue - minValue;
                assert(valueRange > 0);

                auto startAngleDeg = minAngleDeg;
                auto endAngleDeg = maxAngleDeg;

                double angleRange = Math.abs(startAngleDeg - endAngleDeg);

                size_t ticksCount = (valueRange / valueStep).to!size_t;
                assert(ticksCount >= 2);

                if (minValue == 0)
                {
                    ticksCount++;
                }

                double angleDegDiff = angleRange / (ticksCount - 1);
                size_t endIndex = ticksCount - 1;
                assert(endIndex < ticksCount);
                foreach (i; 0 .. ticksCount)
                {
                    auto pos = Vec2d.fromPolarDeg(startAngleDeg, radius - tickOuterPadding);

                    Texture proto = (majorTickStep > 0 && ((i % majorTickStep) == 0)) ? bigTickProto : smallTickProto;

                    proto.angle = startAngleDeg;

                    auto tickX = radius + pos.x - proto.bounds.halfWidth;
                    auto tickY = radius + pos.y - proto.bounds.halfHeight;

                    auto tickBoundsW = proto.width;
                    auto tickBoundsH = proto.height;

                    copyFrom(proto, Rect2d(0, 0, proto.width, proto.height), Rect2d(tickX, tickY, tickBoundsW, tickBoundsH));

                    if ((isShowFirstLastLabel && (i == 0 || i == endIndex)) || (labelStep > 0 &&(i % labelStep == 0)))
                    {
                        auto textPos = Vec2d.fromPolarDeg(startAngleDeg, radius - labelOuterPadding);

                        auto labelText = (i * valueStep).to!dstring;
                        labelProto.text = labelText;
                        labelProto.updateRows(isForce : true);

                        auto textX = radius + textPos.x - labelProto.rowGlyphWidth / 2;
                        auto textY = radius + textPos.y - labelProto.rowGlyphHeight / 2;

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
