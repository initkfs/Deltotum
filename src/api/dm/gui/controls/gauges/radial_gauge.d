module api.dm.gui.controls.gauges.radial_gauge;

import api.dm.kit.sprites.sprite : Sprite;
import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.textures.vectors.shapes.vshape : VShape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.gui.containers.circle_box : CircleBox;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.sprites.textures.texture : Texture;
import api.dm.gui.controls.texts.text : Text;
import api.dm.kit.sprites.transitions.transition : Transition;
import api.dm.kit.sprites.transitions.targets.value_transition : ValueTransition;
import api.dm.kit.assets.fonts.font_size : FontSize;

import api.math.geom2.vec2 : Vec2d;
import api.math.geom2.rect2 : Rect2d;

import Math = api.math;

import std.conv : to;

debug import std.stdio : writeln, writefln;

class Hand : VShape
{
    double handWidth = 0;
    double handHeight = 0;

    Vec2d startPoint;

    this(double textureWidth, double textureHeight, double handWidth, double handHeight, GraphicStyle style)
    {
        super(textureWidth, textureHeight, style);
        this.handWidth = handWidth;
        this.handHeight = handHeight;
        startPoint = Vec2d(width / 2, height / 2);
    }

    override void create()
    {
        super.create;
        import api.dm.com.graphics.com_texture : ComTextureScaleMode;

        textureScaleMode = ComTextureScaleMode.quality;
    }

    override void createTextureContent()
    {
        super.createTextureContent;
        auto gc = canvas;

        gc.color(style.fillColor);
        gc.lineWidth(style.lineWidth);

        const centerX = startPoint.x;
        const centerY = startPoint.y;

        const double halfWidth = handWidth / 2.0;

        enum coneHeight = 5;

        gc.moveTo(centerX - halfWidth, centerY - handHeight + coneHeight);
        gc.lineTo(centerX, centerY - handHeight);
        gc.lineTo(centerX + halfWidth, centerY - handHeight + coneHeight);
        gc.lineTo(centerX + halfWidth, centerY);
        gc.lineTo(centerX - halfWidth, centerY);
        gc.lineTo(centerX - halfWidth, centerY - handHeight + coneHeight);
        gc.fillPreserve;

        gc.color(style.lineColor);
        gc.stroke;
    }
}

struct ZoneColor
{
    double percentTo = 0;
    RGBA color;
}

/**
 * Authors: initkfs
 */
class RadialGauge : Control
{
    double minAngleDeg = 0;
    double maxAngleDeg = 0;

    double minValue = 0;
    double maxValue = 1;
    double valueStep = 0.05;
    size_t labelStepCount = 5;

    Sprite hand;
    Sprite handHolder;

    ValueTransition handTransition;

    Text label;

    protected
    {
        double _diameter = 0;
        double _value;

    }

    this(double diameter, double minAngleDeg, double maxAngleDeg)
    {
        this._diameter = diameter;
        assert(_diameter > 0);

        this._width = diameter;
        this._height = diameter;

        this.minAngleDeg = minAngleDeg;
        this.maxAngleDeg = maxAngleDeg;

        import api.dm.kit.sprites.layouts.center_layout : CenterLayout;

        this.layout = new CenterLayout;

        isDrawBounds = true;
    }

    override void create()
    {
        super.create;

        size_t radius = (_diameter / 2).to!size_t;

        import api.dm.kit.sprites.textures.vectors.vector_texture : VectorTexture;
        import api.dm.kit.sprites.textures.rgba_texture : RgbaTexture;

        const centerShapeW = width;
        const centerShapeH = height;

        handTransition = new ValueTransition(0, 0, 500);
        handTransition.onOldNewValue ~= (oldValue, value) {
            setHandAngleDeg(value);
        };
        handTransition.onStop ~= () { setLabel(_value); };
        addCreate(handTransition);

        import api.dm.kit.sprites.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;
        import api.dm.com.graphics.com_texture : ComTextureScaleMode;

        auto tickWidth = 2;
        auto tickHeight = 6;

        auto smallTickProto = new VConvexPolygon(tickHeight, tickWidth, GraphicStyle(0, graphics.theme.colorAccent, true, graphics
                .theme.colorAccent), 0);
        build(smallTickProto);
        smallTickProto.initialize;
        smallTickProto.create;
        smallTickProto.textureScaleMode = ComTextureScaleMode.quality;

        auto bigTickProto = new VConvexPolygon(tickHeight * 2, tickWidth, GraphicStyle(2, graphics.theme.colorDanger, true, graphics
                .theme.colorDanger), 0);
        build(bigTickProto);
        bigTickProto.initialize;
        bigTickProto.create;
        bigTickProto.textureScaleMode = ComTextureScaleMode.quality;

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

                auto angleRange = Math.abs(startAngleDeg - endAngleDeg);

                size_t ticksCount = (valueRange / valueStep).to!size_t;
                assert(ticksCount >= 2);

                if (minValue == 0)
                {
                    ticksCount++;
                }

                size_t angleDegDiff = (Math.round(angleRange / (ticksCount - 1))).to!size_t;
                size_t endIndex = ticksCount - 1;
                assert(endIndex < ticksCount);
                foreach (i; 0 .. ticksCount)
                {
                    auto pos = Vec2d.fromPolarDeg(startAngleDeg, radius - 35);

                    Texture proto = i % labelStepCount == 0 ? bigTickProto : smallTickProto;

                    proto.angle = startAngleDeg;

                    auto tickX = radius + pos.x - proto.bounds.halfWidth;
                    auto tickY = radius + pos.y - proto.bounds.halfHeight;

                    auto tickBoundsW = proto.width;
                    auto tickBoundsH = proto.height;

                    copyFrom(proto, Rect2d(0, 0, proto.width, proto.height), Rect2d(tickX, tickY, tickBoundsW, tickBoundsH));

                    if (i == 0 || i == endIndex || proto is bigTickProto)
                    {
                        auto textPos = Vec2d.fromPolarDeg(startAngleDeg, radius - 15);

                        auto labelText = (i * valueStep).to!dstring;
                        labelProto.text = labelText;
                        labelProto.updateRows(isForce : true);

                        auto textX = radius + textPos.x - labelProto.rowGlyphWidth / 2;
                        auto textY = radius + textPos.y - labelProto.rowGlyphHeight / 2;

                        double nextX = textX;

                        labelProto.onFontTexture((fontTexture, const glyphPtr) {

                            Rect2d textDest =
                            {
                                nextX, textY, glyphPtr.geometry.width, glyphPtr.geometry.height};

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

            auto handStyle = GraphicStyle(1, graphics.theme.colorDanger, true, graphics
                    .theme.colorDanger);

            hand = new Hand(width, height, 5, 45, handStyle);
            addCreate(hand);

            import api.dm.kit.sprites.textures.vectors.shapes.vregular_polygon : VRegularPolygon;

            VRegularPolygon holder = new VRegularPolygon(10, GraphicStyle(0, graphics.theme.colorDanger, true, graphics
                    .theme.colorDanger));
            addCreate(holder);
            handHolder = holder;

            //setHandAngleDeg(minAngleDeg);
            setHandAngleDeg(minAngleDeg);

            label = new Text("");
            label.isLayoutManaged = false;
            label.fontSize = FontSize.small;
            addCreate(label);

            setLabel(minValue);

            import api.dm.kit.sprites.textures.vectors.vector_texture : VectorTexture;

            auto zoneShape = new class VectorTexture
            {
                this()
                {
                    super(centerShapeW, centerShapeH);
                }

                override void createTextureContent()
                {
                    import Math = api.dm.math;

                    //TODO remove native api
                    import api.dm.sys.cairo.libs;

                    auto cr = cairoContext.getObject;

                    const lineWidth = 6;
                    canvas.lineWidth(lineWidth);

                    auto xCenter = centerShapeW / 2;
                    auto yCenter = centerShapeH / 2;

                    enum rangeParts = 3;

                    const double angleDiff = Math.abs(maxAngleDeg - minAngleDeg) / rangeParts;

                    double startAngle = minAngleDeg;
                    double endAngle = startAngle + angleDiff;

                    RGBA[rangeParts] colors = [
                        graphics.theme.colorSuccess, graphics.theme.colorWarning,
                        graphics.theme.colorDanger
                    ];
                    foreach (i; 0 .. rangeParts)
                    {
                        canvas.color(colors[i]);
                        canvas.arc(xCenter, yCenter, xCenter - 45, Math.degToRad(startAngle), Math.degToRad(endAngle));
                        canvas.stroke;
                        
                        startAngle = endAngle;
                        endAngle += angleDiff;
                    }

                   
                }
            };

            addCreate(zoneShape);

        }

        override void applyLayout()
        {
            super.applyLayout;
            label.x = bounds.middleX - label.bounds.halfWidth;
            label.y = bounds.middleY + label.bounds.height;
        }

        protected void setHandAngleDeg(double angleDeg)
        {
            auto newAngle = (angleDeg + 90);

            if (minAngleDeg < maxAngleDeg)
            {
                newAngle = Math.clamp(newAngle, minAngleDeg, maxAngleDeg + 90);
            }
            else
            {
                newAngle = Math.clamp(newAngle, minAngleDeg, minAngleDeg + (
                        minAngleDeg - maxAngleDeg) + 90);
            }

            hand.angle = newAngle;
            handHolder.angle = newAngle;
        }

        void setLabel(double value)
        {
            label.text = value.to!dstring;
        }

        protected void setHandAngleDegAnim(double angleDeg)
        {
            if (handTransition.isRunning)
            {
                //setHandAngleDeg(handTransition.maxValue);
                handTransition.stop;
            }

            auto oldAngle = hand.angle - 90;

            handTransition.minValue = oldAngle;
            handTransition.maxValue = angleDeg;
            handTransition.run;
        }

        void value(double v)
        {
            double value = Math.clamp(v, minValue, maxValue);

            auto range = Math.abs(maxValue - minValue);
            auto angleRange = Math.abs(minAngleDeg - maxAngleDeg);

            auto angleOffset = value * (angleRange / range);

            auto newAngle = minAngleDeg + angleOffset;
            setHandAngleDegAnim(newAngle);
            _value = value;
        }
    }
