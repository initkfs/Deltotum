module api.dm.gui.controls.clocks.analog_clock;

import api.dm.gui.controls.control : Control;
import api.dm.gui.containers.circle_box : CircleBox;
import api.dm.gui.controls.texts.text : Text;
import api.dm.kit.assets.fonts.font_size : FontSize;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.vector2 : Vector2;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.sprites.textures.vectors.shapes.vcircle : VCircle;
import api.dm.kit.sprites.textures.vectors.shapes.varc : VArc;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites.textures.vectors.shapes.vhexagon : VHexagon;
import api.dm.kit.sprites.textures.vectors.shapes.vregular_polygon : VRegularPolygon;
import api.dm.kit.sprites.textures.vectors.shapes.vshape : VShape;
import api.dm.kit.sprites.transitions.pause_transition : PauseTransition;
import api.dm.kit.sprites.textures.texture : Texture;
import api.math.rect2d : Rect2d;
import Math = api.dm.math;

debug import std.stdio : writeln, writefln;

import std.conv : to;

class Hand : VShape
{
    double handWidth = 0;
    double handHeight = 0;

    Vector2 startPoint;

    this(double textureWidth, double textureHeight, double handWidth, double handHeight, GraphicStyle style)
    {
        super(textureWidth, textureHeight, style);
        this.handWidth = handWidth;
        this.handHeight = handHeight;
        startPoint = Vector2(width / 2, height / 2);
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

/**
 * Authors: initkfs
 */
class AnalogClock : Control
{
    enum defaultDiameter = 220;

    bool isPreciseMinSecLabels;

    Sprite hourHand;
    Sprite minHand;
    Sprite secHand;

    Sprite handHolder;

    PauseTransition clockAnimation;

    bool isAutorun;

    Sprite[] secIndicatorSegments;

    private
    {
        bool isCheckFillSecs;
        size_t lastSecIndex;
    }

    version (DmAddon)
    {
        import api.dm.addon.gui.controls.indicators.seven_segment : SevenSegment;

        SevenSegment hour1;
        SevenSegment hour2;

        SevenSegment min1;
        SevenSegment min2;

        SevenSegment sec1;
        SevenSegment sec2;
    }

    this(size_t diameter = defaultDiameter)
    {
        this.width = diameter;
        this.height = diameter;

        import api.dm.kit.sprites.layouts.center_layout : CenterLayout;

        this.layout = new CenterLayout;
        if (diameter == defaultDiameter)
        {
            isPreciseMinSecLabels = true;
        }

        isManagedByScene = true;
    }

    override void create()
    {
        super.create;

        size_t radius = (width / 2).to!size_t;

        enum minorTickOffset = 15;
        enum labelOffset = 30;

        double minorTickSize = 4;
        double majorTickSize = 6;

        auto minorTickProto = new VCircle(minorTickSize, GraphicStyle(0, graphics.theme.colorAccent, true, graphics
                .theme.colorAccent));
        build(minorTickProto);
        minorTickProto.initialize;
        minorTickProto.create;

        auto majorTickProto = new VCircle(majorTickSize, GraphicStyle(0, graphics.theme.colorDanger, true, graphics
                .theme.colorDanger));
        build(majorTickProto);
        majorTickProto.initialize;
        majorTickProto.create;

        import api.dm.kit.assets.fonts.font_size : FontSize;

        auto labelProto = new Text;
        build(labelProto);
        labelProto.initialize;
        labelProto.create;

        scope (exit)
        {
            minorTickProto.dispose;
            majorTickProto.dispose;
            labelProto.dispose;
        }

        import api.dm.kit.sprites.textures.rgba_texture : RgbaTexture;

        const centerShapeW = width;
        const centerShapeH = height;

        auto centerShape = new class RgbaTexture
        {
            this()
            {
                super(centerShapeW, centerShapeH);
            }

            const ticksCount = 60;
            const angleOffset = 360.0 / ticksCount;

            double endAngle = 360;

            double currAngle = 0;

            override void createTextureContent()
            {
                foreach (i; 0 .. ticksCount)
                {
                    // if (i == (ticksCount - 1))
                    // {
                    //     currAngle = endAngle;
                    // }

                    Texture proto = ((i % 5) == 0) ? majorTickProto : minorTickProto;

                    if (!cast(VCircle) proto)
                    {
                        proto.angle = currAngle;
                    }

                    auto tickPos = Vector2.fromPolarDeg(currAngle, radius - minorTickOffset);
                    auto tickX = radius + tickPos.x - proto.bounds.halfWidth;
                    auto tickY = radius + tickPos.y - proto.bounds.halfHeight;

                    auto tickBoundsW = proto.width;
                    auto tickBoundsH = proto.height;

                    copyFrom(proto, Rect2d(0, 0, proto.width, proto.height), Rect2d(tickX, tickY, tickBoundsW, tickBoundsH));

                    if (proto is majorTickProto)
                    {
                        auto textPos = Vector2.fromPolarDeg(currAngle, radius - labelOffset);

                        size_t hourNum = (i / 5 + 3) % 12;
                        if (hourNum == 0)
                        {
                            hourNum = 12;
                        }

                        auto labelText = (hourNum).to!dstring;
                        labelProto.text = labelText;
                        labelProto.updateRows(isForce : true);

                        auto glyphWidth = labelProto.rowGlyphWidth;
                        auto glyphHeight = labelProto.rowGlyphHeight;

                        auto textX = radius + textPos.x - glyphWidth / 2;
                        auto textY = radius + textPos.y - glyphHeight / 2;

                        double nextW = textX;

                        labelProto.onFontTexture((fontTexture, const glyphPtr) {

                            Rect2d textDest = {
                                nextW, textY, glyphPtr.geometry.width, glyphPtr.geometry.height
                            };

                            copyFrom(fontTexture, glyphPtr.geometry, textDest);
                            nextW += glyphPtr.geometry.width;
                            return true;
                        });
                    }

                    currAngle += angleOffset;
                }
            }
        };

        addCreate(centerShape);

        auto hourStyle = GraphicStyle(3, graphics.theme.colorAccent, true, graphics
                .theme.colorWarning);

        hourHand = new Hand(width, height, 6, 55, hourStyle);
        addCreate(hourHand);

        auto minStyle = hourStyle;

        minHand = new Hand(width, height, 6, 70, minStyle);
        addCreate(minHand);

        auto secStyle = GraphicStyle(1, graphics.theme.colorDanger, true, graphics
                .theme.colorDanger);

        secHand = new Hand(width, height, 5, 75, secStyle);
        addCreate(secHand);

        VHexagon holder = new VHexagon(15, GraphicStyle(0, graphics.theme.colorDanger, true, graphics
                .theme.colorDanger));
        addCreate(holder);
        handHolder = holder;

        import api.dm.com.graphics.com_texture : ComTextureScaleMode;

        holder.textureScaleMode = ComTextureScaleMode.quality;

        foreach (i; 0 .. 60)
        {
            auto segment = new VArc(radius, GraphicStyle(5, graphics.theme.colorAccent), width, width);
            segment.xCenter = 0;
            segment.yCenter = 0;

            auto angleOffset = 360 / 60 / 2;
            auto stAngle = 360.0 / 60 * i + angleOffset - 90;
            auto endAngle = stAngle + 360 / 60;
            segment.fromAngleRad = Math.degToRad(stAngle);
            segment.toAngleRad = Math.degToRad(endAngle);
            addCreate(segment);
            segment.isVisible = false;
            secIndicatorSegments ~= segment;
            //segment.angle = 360.0 * i / 60.0;
        }

        version (DmAddon)
        {
            import api.dm.gui.containers.hbox : HBox;

            auto segmentLayout = new HBox(2);
            segmentLayout.margin.top = 20;
            addCreate(segmentLayout);

            enum sWidgh = 15;
            enum sHeight = 25;

            SevenSegment createSegment()
            {
                auto s = new class SevenSegment
                {
                    this()
                    {
                        super(sWidgh, sHeight);
                    }

                    override GraphicStyle createSegmentStyle()
                    {
                        GraphicStyle style = createDefaultStyle;
                        style.isFill = true;
                        style.lineWidth = 2;
                        style.lineColor = graphics.theme.colorSecondary;
                        style.fillColor = graphics.theme.colorDanger;
                        return style;
                    }
                };
                //s.isDrawBounds = true;
                s.hSegmentWidth = 8;
                s.hSegmentHeight = 3;
                s.vSegmentWidth = 3;
                s.vSegmentHeight = 8;
                s.segmentCornerBevel = 2;
                s.segmentSpacing = 2;
                return s;
            }

            hour1 = createSegment;
            hour2 = createSegment;

            segmentLayout.addCreate(hour1);
            segmentLayout.addCreate(hour2);

            segmentLayout.addCreate(new Text(":"));

            min1 = createSegment;
            min2 = createSegment;

            segmentLayout.addCreate(min1);
            segmentLayout.addCreate(min2);
            segmentLayout.addCreate(new Text(":"));

            sec1 = createSegment;
            sec2 = createSegment;

            segmentLayout.addCreate(sec1);
            segmentLayout.addCreate(sec2);

        }

        if (!clockAnimation)
        {
            clockAnimation = new PauseTransition(1000);
            clockAnimation.isInfinite = true;
            clockAnimation.onEnd ~= () {
                import std.datetime;

                auto curr = Clock.currTime();
                setTime(curr.hour, curr.minute, curr.second);
            };
            addCreate(clockAnimation);
        }

        if (isAutorun)
        {
            clockAnimation.run;
        }

        run;
    }

    override void pause()
    {
        super.pause;
        isCheckFillSecs = true;
    }

    void setTime(ubyte hour, ubyte min, ubyte sec)
    {
        assert(hourHand);
        assert(minHand);
        assert(secHand);

        version (DmAddon)
        {
            if (hour >= 10)
            {
                hour1.show0to9(hour / 10);
                hour2.show0to9(hour % 10);
            }
            else
            {
                hour1.show0to9(0);
                hour2.show0to9(hour % 10);
            }

            if (min >= 10)
            {
                min1.show0to9(min / 10);
                min2.show0to9(min % 10);
            }
            else
            {
                min1.show0to9(0);
                min2.show0to9(min % 10);
            }

            if (sec >= 10)
            {
                sec1.show0to9(sec / 10);
                sec2.show0to9(sec % 10);
            }
            else
            {
                sec1.show0to9(0);
                sec2.show0to9(sec % 10);
            }
        }

        assert(secIndicatorSegments.length == 60);

        if (sec == 0)
        {
            foreach (Sprite s; secIndicatorSegments)
            {
                s.isVisible = false;
            }
        }

        auto index = sec % secIndicatorSegments.length;
        if (sec == 0)
        {
            index = secIndicatorSegments.length - 1;
        }
        else
        {
            index--;
        }

        if (isCheckFillSecs)
        {
            auto nextIndex = lastSecIndex + 1;
            if (nextIndex < index)
            {
                foreach (i; nextIndex .. index)
                {
                    secIndicatorSegments[i].isVisible = true;
                }
            }
            else
            {
                //TODO bounds
                foreach (i; (index + 1) .. secIndicatorSegments.length)
                {
                    secIndicatorSegments[i].isVisible = false;
                }

                foreach (i; 0 .. index)
                {
                    secIndicatorSegments[i].isVisible = true;
                }
            }
            isCheckFillSecs = false;
        }

        secIndicatorSegments[index].isVisible = true;

        lastSecIndex = index;

        //assert(hour >= 1 && hour <= 12);

        // auto hourDeg = 30.0 * hour + min / 2.0; //converting current time
        // auto minDeg = 6.0 * min;
        // auto secDeg = 6.0 * sec;

        const secDeg = ((sec / 60.0) * 360.0);
        const minDeg = ((min / 60.0) * 360.0) + ((sec / 60.0) * 6.0);
        const hourDeg = ((hour / 12.0) * 360.0) + ((min / 60.0) * 30.0);

        hourHand.angle = hourDeg;
        minHand.angle = minDeg;
        secHand.angle = secDeg;
        handHolder.angle = secDeg;
    }

}
