module api.dm.gui.controls.meters.clocks.digitals.faces.digital_clock_face;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.indicators.sevsegments.seven_segment : SevenSegment;

/**
 * Authors: initkfs
 */
class DigitalClockFace : Control
{
    Sprite2d minHourSeparator;
    Sprite2d delegate(Sprite2d) onNewMinHourSeparator;
    void delegate(Sprite2d) onConfiguredMinHourSeparator;
    void delegate(Sprite2d) onCreatedMinHourSeparator;

    float minHourSeparatorWidth = 0;
    float minHourSeparatorHeight = 0;

    SevenSegment hour1;
    SevenSegment delegate(SevenSegment) onNewHour1Segment;
    void delegate(SevenSegment) onConfiguredHour1Segment;
    void delegate(SevenSegment) onCreatedHour1Segment;

    SevenSegment hour2;
    SevenSegment delegate(SevenSegment) onNewHour2Segment;
    void delegate(SevenSegment) onConfiguredHour2Segment;
    void delegate(SevenSegment) onCreatedHour2Segment;

    float hourSegmentWidth = 0;
    float hourSegmentHeight = 0;

    SevenSegment min1;
    SevenSegment delegate(SevenSegment) onNewMin1Segment;
    void delegate(SevenSegment) onConfiguredMin1Segment;
    void delegate(SevenSegment) onCreatedMin1Segment;

    SevenSegment min2;
    SevenSegment delegate(SevenSegment) onNewMin2Segment;
    void delegate(SevenSegment) onConfiguredMin2Segment;
    void delegate(SevenSegment) onCreatedMin2Segment;

    float minSegmentWidth = 0;
    float minSegmentHeight = 0;

    SevenSegment sec1;
    SevenSegment delegate(SevenSegment) onNewSec1Segment;
    void delegate(SevenSegment) onConfiguredSec1Segment;
    void delegate(SevenSegment) onCreatedSec1Segment;

    SevenSegment sec2;
    SevenSegment delegate(SevenSegment) onNewSec2Segment;
    void delegate(SevenSegment) onConfiguredSec2Segment;
    void delegate(SevenSegment) onCreatedSec2Segment;

    float secSegmentWidth = 0;
    float secSegmentHeight = 0;

    SevenSegment delegate(SevenSegment) onNewSecSegment;
    void delegate(SevenSegment) onConfiguredSecSegment;
    void delegate(SevenSegment) onCreatedSecSegment;

    this(float width = 0, float height = 0)
    {
        initSize(width, height);

        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

        layout = new HLayout;
        layout.isAutoResize = true;
    }

    override void loadTheme()
    {
        super.loadTheme;

        import Math = api.math;

        if (height == 0)
        {
            height = theme.controlDefaultHeight;
        }

        auto majorSegmentWidth = theme.meterThumbWidth / 2;
        auto majorSegmentHeight = height;

        if (minHourSeparatorWidth == 0)
        {
            minHourSeparatorWidth = majorSegmentWidth * Math.goldUnitFrac;
        }

        if (minHourSeparatorHeight == 0)
        {
            minHourSeparatorHeight = majorSegmentHeight;
        }

        if (hourSegmentWidth == 0)
        {
            hourSegmentWidth = majorSegmentWidth;
        }

        if (hourSegmentHeight == 0)
        {
            hourSegmentHeight = majorSegmentHeight;
        }

        if (minSegmentWidth == 0)
        {
            minSegmentWidth = majorSegmentWidth;
        }

        if (minSegmentHeight == 0)
        {
            minSegmentHeight = majorSegmentHeight;
        }

        auto minorSegmentWidth = majorSegmentWidth * Math.goldUnitFrac;
        auto minorSegmentHeight = majorSegmentHeight * Math.goldUnitFrac;

        if (secSegmentWidth == 0)
        {
            secSegmentWidth = minorSegmentWidth;
        }

        if (secSegmentHeight == 0)
        {
            secSegmentHeight = minorSegmentHeight;
        }

    }

    override void create()
    {
        super.create;

        if (!hour1)
        {
            auto h1 = newHourSegment(hourSegmentWidth, hourSegmentHeight);
            hour1 = !onNewHour1Segment ? h1 : onNewHour1Segment(h1);
            if (onConfiguredHour1Segment)
            {
                onConfiguredHour1Segment(hour1);
            }
            addCreate(hour1);
            if (onCreatedHour1Segment)
            {
                onCreatedHour1Segment(hour1);
            }
        }

        if (!hour2)
        {
            auto h2 = newHourSegment(hourSegmentWidth, hourSegmentHeight);
            hour2 = !onNewHour2Segment ? h2 : onNewHour2Segment(h2);
            if (onConfiguredHour2Segment)
            {
                onConfiguredHour2Segment(hour2);
            }
            addCreate(hour2);
            if (onCreatedHour2Segment)
            {
                onCreatedHour2Segment(hour2);
            }
        }

        if (!minHourSeparator)
        {
            auto minHourSep = newMinHourSeparator(minHourSeparatorWidth, minHourSeparatorHeight);
            minHourSeparator = !onNewMinHourSeparator ? minHourSep : onNewMinHourSeparator(
                minHourSep);

            if (onConfiguredMinHourSeparator)
            {
                onConfiguredMinHourSeparator(minHourSeparator);
            }

            addCreate(minHourSeparator);
            if (onCreatedMinHourSeparator)
            {
                onCreatedMinHourSeparator(minHourSeparator);
            }
        }

        if (!min1)
        {
            auto m1 = newMinSegment(minSegmentWidth, minSegmentHeight);
            min1 = !onNewMin1Segment ? m1 : onNewMin1Segment(m1);
            if (onConfiguredMin1Segment)
            {
                onConfiguredMin1Segment(min1);
            }
            addCreate(min1);
            if (onCreatedMin1Segment)
            {
                onCreatedMin1Segment(min1);
            }
        }

        if (!min2)
        {
            auto m2 = newMinSegment(minSegmentWidth, minSegmentHeight);
            min2 = !onNewMin2Segment ? m2 : onNewMin2Segment(m2);
            if (onConfiguredMin2Segment)
            {
                onConfiguredMin2Segment(min2);
            }
            addCreate(min2);
            if (onCreatedMin2Segment)
            {
                onCreatedMin2Segment(min2);
            }
        }

        if (!sec1)
        {
            auto s1 = newSecSegment(secSegmentWidth, secSegmentHeight);
            sec1 = !onNewSec1Segment ? s1 : onNewSec1Segment(s1);
            
            sec1.isLayoutInvertY = true;
            
            if (onConfiguredSec1Segment)
            {
                onConfiguredSec1Segment(sec1);
            }
            addCreate(sec1);
            if (onCreatedSec1Segment)
            {
                onCreatedSec1Segment(sec1);
            }
        }

        if (!sec2)
        {
            auto s2 = newSecSegment(secSegmentWidth, secSegmentHeight);
            sec2 = !onNewSec2Segment ? s2 : onNewSec2Segment(s2);
            
            sec2.isLayoutInvertY = true;
            
            if (onConfiguredSec2Segment)
            {
                onConfiguredSec2Segment(sec2);
            }
            addCreate(sec2);
            if (onCreatedSec2Segment)
            {
                onCreatedSec2Segment(sec2);
            }
        }
    }

    SevenSegment newHourSegment(float w, float h) => new SevenSegment(w, h);
    SevenSegment newMinSegment(float w, float h) => new SevenSegment(w, h);
    SevenSegment newSecSegment(float w, float h) => new SevenSegment(w, h);

    Sprite2d newMinHourSeparator(float nw, float nh)
    {
        import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
        import api.math.geom2.vec2 : Vec2f;

        auto sepTexture = new Texture2d(nw, nh);
        buildInitCreate(sepTexture);
        sepTexture.createTargetRGBA32;
        sepTexture.setRenderTarget;
        scope (exit)
        {
            sepTexture.restoreRenderTarget;
        }
        graphic.clearTransparent;

        auto dotRadius = nw / 3;

        auto hOffset = nh / 3;

        auto dot1Center = Vec2f(nw / 2, 1.5 * hOffset);
        auto dot2Center = dot1Center;
        dot2Center.y += hOffset;

        if (!platform.cap.isVector)
        {
            graphic.color(theme.colorAccent);
            scope (exit)
            {
                graphic.restoreColor;
            }

            graphic.fillCircle(dot1Center, dotRadius);
            graphic.fillCircle(dot2Center, dotRadius);
        }
        else
        {
            import api.dm.kit.sprites2d.textures.vectors.vector_texture : VectorTexture;

            auto dotProto = new class VectorTexture
            {
                this()
                {
                    super(nw, nh);
                }

                override void createContent()
                {
                    auto ctx = canvas;
                    float startAngleDeg = 0, endAngleDeg = 360;
                    ctx.color = theme.colorAccent;
                    ctx.arc(dot1Center.x, dot1Center.y, dotRadius, startAngleDeg, endAngleDeg);
                    ctx.fill;
                    ctx.arc(dot2Center.x, dot2Center.y, dotRadius, startAngleDeg, endAngleDeg);
                    ctx.fill;
                }
            };

            buildInitCreate(dotProto);
            scope (exit)
            {
                dotProto.dispose;
            }
            dotProto.draw(0);
        }

        if (hour1)
        {
            //TODO angle?
            sepTexture.bestScaleMode;
            sepTexture.angle = hour1.segmentAngle;
        }

        return sepTexture;
    }

    bool setTime(ubyte hour, ubyte min, ubyte sec)
    {
        if (minHourSeparator)
        {
            minHourSeparator.isVisible = !minHourSeparator.isVisible;
        }

        enum dec = 10;
        if (hour >= dec)
        {
            hour1.show0to9(hour / dec);
            hour2.show0to9(hour % dec);
        }
        else
        {
            hour1.show0to9(0);
            hour2.show0to9(hour % dec);
        }

        if (min >= dec)
        {
            min1.show0to9(min / dec);
            min2.show0to9(min % dec);
        }
        else
        {
            min1.show0to9(0);
            min2.show0to9(min % dec);
        }

        if (sec >= dec)
        {
            sec1.show0to9(sec / dec);
            sec2.show0to9(sec % dec);
        }
        else
        {
            sec1.show0to9(0);
            sec2.show0to9(sec % dec);
        }
        return true;
    }

}
