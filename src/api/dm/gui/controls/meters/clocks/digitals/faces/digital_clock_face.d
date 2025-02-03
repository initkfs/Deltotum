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

    double minHourSeparatorWidth = 0;
    double minHourSeparatorHeight = 0;

    SevenSegment hour1;
    SevenSegment hour2;

    double hourSegmentWidth = 0;
    double hourSegmentHeight = 0;

    SevenSegment delegate(SevenSegment) onNewHourSegment;
    void delegate(SevenSegment) onConfiguredHourSegment;
    void delegate(SevenSegment) onCreatedHourSegment;

    SevenSegment min1;
    SevenSegment min2;

    double minSegmentWidth = 0;
    double minSegmentHeight = 0;

    SevenSegment delegate(SevenSegment) onNewMinSegment;
    void delegate(SevenSegment) onConfiguredMinSegment;
    void delegate(SevenSegment) onCreatedMinSegment;

    SevenSegment sec1;
    SevenSegment sec2;

    double secSegmentWidth = 0;
    double secSegmentHeight = 0;

    SevenSegment delegate(SevenSegment) onNewSecSegment;
    void delegate(SevenSegment) onConfiguredSecSegment;
    void delegate(SevenSegment) onCreatedSecSegment;

    this(double width = 0, double height = 0)
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
            hour1 = createSegment(newHourSegment(hourSegmentWidth, hourSegmentHeight), this, onNewHourSegment, onConfiguredHourSegment, onCreatedHourSegment);
        }

        if (!hour2)
        {
            hour2 = createSegment(newHourSegment(hourSegmentWidth, hourSegmentHeight), this, onNewHourSegment, onConfiguredHourSegment, onCreatedHourSegment);
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
            min1 = createSegment(newMinSegment(minSegmentWidth, minSegmentHeight), this, onNewMinSegment, onConfiguredMinSegment, onCreatedMinSegment);
        }

        if (!min2)
        {
            min2 = createSegment(newMinSegment(minSegmentWidth, minSegmentHeight), this, onNewMinSegment, onConfiguredMinSegment, onCreatedMinSegment);
        }

        if (!sec1)
        {
            sec1 = createSegment(newSecSegment(secSegmentWidth, secSegmentHeight), this, onNewSecSegment, onConfiguredSecSegment, onCreatedSecSegment);
        }

        if (!sec2)
        {
            sec2 = createSegment(newSecSegment(secSegmentWidth, secSegmentHeight), this, onNewSecSegment, onConfiguredSecSegment, onCreatedSecSegment);
        }
    }

    protected SevenSegment createSegment(SevenSegment segment, Control root, SevenSegment delegate(SevenSegment) onNew, void delegate(
            SevenSegment) onConfigured, void delegate(SevenSegment) onCreated)
    {
        assert(segment);
        assert(root);

        auto newSegment = !onNew ? segment : onNew(segment);

        if (onConfigured)
        {
            onConfigured(newSegment);
        }

        root.addCreate(newSegment);
        if (onCreated)
        {
            onCreated(newSegment);
        }
        return newSegment;
    }

    SevenSegment newHourSegment(double w, double h) => new SevenSegment(w, h);
    SevenSegment newMinSegment(double w, double h) => new SevenSegment(w, h);
    SevenSegment newSecSegment(double w, double h) => new SevenSegment(w, h);

    Sprite2d newMinHourSeparator(double w, double h)
    {
        import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
        import api.math.geom2.vec2 : Vec2d;

        auto sepTexture = new Texture2d(w, h);
        buildInitCreate(sepTexture);
        sepTexture.createTargetRGBA32;
        sepTexture.setRendererTarget;
        scope (exit)
        {
            sepTexture.restoreRendererTarget;
        }
        graphics.clearTransparent;

        auto dotRadius = w / 3;

        auto hOffset = h / 3;

        auto dot1Center = Vec2d(w / 2, 1.5 * hOffset);
        auto dot2Center = dot1Center;
        dot2Center.y += hOffset;

        if (!capGraphics.isVectorGraphics)
        {
            graphics.changeColor(theme.colorAccent);
            scope (exit)
            {
                graphics.restoreColor;
            }

            graphics.fillCircle(dot1Center, dotRadius);
            graphics.fillCircle(dot2Center, dotRadius);
        }
        else
        {
            import api.dm.kit.sprites2d.textures.vectors.vector_texture : VectorTexture;

            auto dotProto = new class VectorTexture
            {
                this()
                {
                    super(w, h);
                }

                override void createTextureContent()
                {
                    auto ctx = canvas;
                    double startAngleDeg = 0, endAngleDeg = 360;
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
            dotProto.draw;
        }

        if (hour1)
        {
            //TODO angle?
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
