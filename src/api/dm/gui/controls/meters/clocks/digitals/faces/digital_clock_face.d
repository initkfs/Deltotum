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
    Sprite2d delegate() onNewMinHourSeparator;
    void delegate(Sprite2d) onConfiguredMinHourSeparator;
    void delegate(Sprite2d) onCreatedMinHourSeparator;

    float minHourSeparatorWidth = 0;
    float minHourSeparatorHeight = 0;

    SevenSegment hour1;
    SevenSegment delegate() onNewHour1Segment;
    void delegate(SevenSegment) onConfiguredHour1Segment;
    void delegate(SevenSegment) onCreatedHour1Segment;

    SevenSegment hour2;
    SevenSegment delegate() onNewHour2Segment;
    void delegate(SevenSegment) onConfiguredHour2Segment;
    void delegate(SevenSegment) onCreatedHour2Segment;

    float hourSegmentWidth = 0;
    float hourSegmentHeight = 0;

    SevenSegment min1;
    SevenSegment delegate() onNewMin1Segment;
    void delegate(SevenSegment) onConfiguredMin1Segment;
    void delegate(SevenSegment) onCreatedMin1Segment;

    SevenSegment min2;
    SevenSegment delegate() onNewMin2Segment;
    void delegate(SevenSegment) onConfiguredMin2Segment;
    void delegate(SevenSegment) onCreatedMin2Segment;

    float minSegmentWidth = 0;
    float minSegmentHeight = 0;

    SevenSegment sec1;
    SevenSegment delegate() onNewSec1Segment;
    void delegate(SevenSegment) onConfiguredSec1Segment;
    void delegate(SevenSegment) onCreatedSec1Segment;

    SevenSegment sec2;
    SevenSegment delegate() onNewSec2Segment;
    void delegate(SevenSegment) onConfiguredSec2Segment;
    void delegate(SevenSegment) onCreatedSec2Segment;

    float secSegmentWidth = 0;
    float secSegmentHeight = 0;

    SevenSegment delegate() onNewSecSegment;
    void delegate(SevenSegment) onConfiguredSecSegment;
    void delegate(SevenSegment) onCreatedSecSegment;

    this(float width = 0, float height = 0)
    {
        initSize(width, height);

        id = "digital_clock_face";

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
            hour1 = !onNewHour1Segment ? newHourSegment(hourSegmentWidth, hourSegmentHeight) : onNewHour1Segment();
            hour1.id = "dg_clock_segment_hour1";
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
            hour2 = !onNewHour2Segment ? newHourSegment(hourSegmentWidth, hourSegmentHeight) : onNewHour2Segment();
            hour2.id = "dg_clock_segment_hour2";
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
            minHourSeparator = !onNewMinHourSeparator ? newMinHourSeparator(minHourSeparatorWidth, minHourSeparatorHeight) : onNewMinHourSeparator();
            minHourSeparator.id = "dg_clock_minhour_sep";
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
            min1 = !onNewMin1Segment ? newMinSegment(minSegmentWidth, minSegmentHeight) : onNewMin1Segment();
            min1.id = "dg_clock_segment_min1";
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
            min2 = !onNewMin2Segment ? newMinSegment(minSegmentWidth, minSegmentHeight) : onNewMin2Segment();
            min2.id = "dg_clock_segment_min2";
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
            sec1 = !onNewSec1Segment ? newSecSegment(secSegmentWidth, secSegmentHeight) : onNewSec1Segment();
            sec1.id = "dg_clock_segment_sec1";
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
            sec2 = !onNewSec2Segment ? newSecSegment(secSegmentWidth, secSegmentHeight) : onNewSec2Segment();
            sec2.id = "dg_clock_segment_sec2";
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
        import api.dm.kit.sprites2d.textures.tex2d : Tex2d;
        import api.math.geom2.vec2 : Vec2f;

        auto sepTexture = new Tex2d(nw, nh);
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
            import api.dm.kit.sprites2d.textures.vectors.vec_tex : VecTex;

            auto dotProto = new class VecTex
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
