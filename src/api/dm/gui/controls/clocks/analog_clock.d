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
import Math = api.dm.math;

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
        isDrawBounds = true;
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
        auto gc = gContext;

        gc.setColor(style.fillColor);
        gc.setLineWidth(style.lineWidth);

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

        gc.setColor(style.lineColor);
        gc.stroke;
    }
}

/**
 * Authors: initkfs
 */
class AnalogClock : Control
{
    enum defaultDiameter = 200;

    bool isPreciseMinSecLabels;

    Sprite hourHand;
    Sprite minHand;
    Sprite secHand;

    Sprite handHolder;

    PauseTransition clockAnimation;

    bool isAutorun = true;

    Sprite[] secIndicatorSegments;

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
    }

    override void create()
    {
        super.create;

        size_t radius = (width / 2).to!size_t;

        enum labelsOffsest = 28;
        enum unitOffset = 12;

        auto startAngle = 0;

        auto labelBox = new CircleBox(radius - labelsOffsest, 300);
        addCreate(labelBox);

        foreach (int i; 1 .. 13)
        {
            auto text = i.to!dstring;
            auto label = new Text(text);
            labelBox.addCreate(label);
        }

        auto unitLabelBox = new CircleBox(radius - unitOffset, startAngle);
        addCreate(unitLabelBox);

        foreach (int i; 0 .. 60)
        {
            //
            auto text = "∙";
            if (i % 5 == 0)
            {
                text = "●";
            }
            auto minSecLabel = new Text(text);

            if (isPreciseMinSecLabels)
            {
                //preciseMinSecLabels(i, minSecLabel);
            }

            unitLabelBox.addCreate(minSecLabel);
        }

        VCircle centerShape = new VCircle(5, GraphicStyle(1, graphics.theme.colorText, true, graphics
                .theme.colorText));
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
        
        import api.dm.com.graphics.com_texture: ComTextureScaleMode;
        holder.textureScaleMode = ComTextureScaleMode.quality;

        //auto outerSecIndicator = new CircleBox(width + 20, 0);
        //outerSecIndicator.isDrawBounds = true;
        //addCreate(outerSecIndicator);

        //const double circumference = 2 * Math.PI * width;
        //const double segments = 60;
        //double segmentWidth = circumference / segments;

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
            clockAnimation.isCycle = true;
            clockAnimation.onEndFrames ~= () {
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
        secIndicatorSegments[index].isVisible = true;

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

    void preciseMinSecLabels(size_t i, Text minSecLabel)
    {
        // if (i == 3 || i == 32)
        // {
        //     minSecLabel.margin.left = 1;
        // }
        // if (i == 58 || i == 27)
        // {
        //     minSecLabel.margin.left = -1;
        // }

        // if (i == 42 || i == 48)
        // {
        //     minSecLabel.margin.top = 1;
        // }

        // if (i == 8 || i == 12 || i == 18)
        // {
        //     minSecLabel.margin.top = -1;
        // }
    }

}
