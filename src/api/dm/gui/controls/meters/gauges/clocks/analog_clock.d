module api.dm.gui.controls.meters.gauges.clocks.analog_clock;

import api.dm.gui.controls.meters.gauges.base_radial_gauge : BaseRadialGauge;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.meters.hands.meter_hand_factory : MeterHandFactory;
import api.dm.gui.controls.indicators.segmentbars.radial_segmentbar : RadialSegmentBar;

import api.dm.kit.sprites2d.tweens.pause_tween2d : PauseTween2d;
import api.dm.kit.sprites2d.tweens.tween2d : Tween2d;
import api.dm.gui.controls.meters.scales.statics.rscale_static : RScaleStatic;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.geom2.vec2 : Vec2d;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.math.geom2.rect2 : Rect2d;

import Math = api.dm.math;

debug import std.stdio : writeln, writefln;

import std.conv : to;

/**
 * Authors: initkfs
 */
class AnalogClock : BaseRadialGauge
{
    RadialSegmentBar progressBar;

    Sprite2d hourHand;
    bool isCreateHourHand = true;
    Sprite2d delegate(Sprite2d) onNewHourHand;
    void delegate(Sprite2d) onConfiguredHourHand;
    void delegate(Sprite2d) onCreatedHourHand;

    Sprite2d minHand;
    bool isCreateMinHand = true;
    Sprite2d delegate(Sprite2d) onNewMinHand;
    void delegate(Sprite2d) onConfiguredMinHand;
    void delegate(Sprite2d) onCreatedMinHand;

    Sprite2d secHand;
    bool isCreateSecHand = true;
    Sprite2d delegate(Sprite2d) onNewSecHand;
    void delegate(Sprite2d) onConfiguredSecHand;
    void delegate(Sprite2d) onCreatedSecHand;

    Sprite2d handHolder;
    bool isCreateHandHolder = true;
    Sprite2d delegate(Sprite2d) onNewHandHolder;
    void delegate(Sprite2d) onConfiguredHandHolder;
    void delegate(Sprite2d) onCreatedHandHolder;

    Tween2d clockAnimation;
    bool isCreateClockAnimation = true;
    Tween2d delegate(Tween2d) onNewClockAnimation;
    void delegate(Sprite2d) onConfiguredClockAnimation;
    void delegate(Tween2d) onCreatedClockAnimation;

    double handWidth = 0;

    bool isAutorun;

    protected
    {
        bool isCheckFillSecs;
        size_t lastSecIndex;

        MeterHandFactory handFactory;
    }

    this(double diameter = 0)
    {
        super(diameter, 0, 60, 0, 360);
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadAnalogClockTheme;
    }

    void loadAnalogClockTheme()
    {
        if (handWidth == 0)
        {
            handWidth = theme.meterHandWidth * 2;
            assert(handWidth > 0);
        }
    }

    protected Vec2d handCone(double size)
    {
        const goldenRes = Math.goldenDiv(size);
        return Vec2d(goldenRes.shortest, goldenRes.longest);
    }

    Sprite2d newHourHand()
    {
        assert(handFactory);

        auto handHeight = diameter * 0.27;

        auto handStyle = createHandStyle;
        if (!handStyle.isPreset)
        {
            handStyle.fillColor = theme.colorWarning;
        }

        auto cone = handCone(handHeight);
        auto newHand = handFactory.createHand(handWidth, handHeight, handStyle, cone.x, cone.y);
        return newHand;
    }

    Sprite2d newMinHand()
    {
        assert(handFactory);

        auto handHeight = diameter * 0.32;
        auto handStyle = createHandStyle;

        if (!handStyle.isPreset)
        {
            handStyle.fillColor = theme.colorWarning;
        }

        auto cone = handCone(handHeight);
        cone.x /= 2;
        auto newHand = handFactory.createHand(handWidth, handHeight, handStyle, cone.x, cone.y);
        return newHand;
    }

    Sprite2d newSecHand()
    {
        assert(handFactory);

        auto handHeight = diameter * 0.35;
        auto handStyle = createHandStyle;
        if (!handStyle.isPreset)
        {
            handStyle.fillColor = theme.colorSuccess;
            handStyle.lineColor = theme.colorDanger;
        }

        auto cone = handCone(handHeight);
        cone.x = 0;
        auto newHand = handFactory.createHand(handWidth, handHeight, handStyle, cone.x, cone.y);
        return newHand;
    }

    Tween2d newClockAnimation()
    {
        return new PauseTween2d(1000);
    }

    Sprite2d newHandHolder()
    {
        auto style = createFillStyle;
        if (!style.isPreset)
        {
            style.fillColor = theme.colorDanger;
            style.lineColor = theme.colorDanger;
        }

        auto size = radius * 0.2;
        return theme.regularPolyShape(size, 6, angle, style);
    }

    override RScaleStatic newScale()
    {
        auto size = diameter * 0.9;
        auto scale = new RScaleStatic(size, minAngleDeg, maxAngleDeg);
        scale.isLastTickMajorTick = false;
        scale.onVTickIsContinue = (ctx, Rect2d tickBounds, bool isMajorTick) {
            auto style = createFillStyle;
            ctx.color = style.fillColor;

            if (!style.isPreset && isMajorTick)
            {
                ctx.color = theme.colorDanger;
            }

            auto tickRadius = isMajorTick ? scale.tickMajorHeight / 2.5 : scale.tickMinorHeight / 2.5;
            const center = tickBounds.center;
            ctx.beginPath;
            ctx.arc(center.x, center.y, tickRadius, 0, 360);
            ctx.closePath;
            ctx.fill;
            return false;
        };
        scale.labelTextProvider = (size_t labelIndex, size_t tickIndex, Vec2d pos, bool isMajorTick, double offsetTick) {
            size_t hourNum = (tickIndex / 5 + 3) % 12;
            if (hourNum == 0)
            {
                hourNum = 12;
            }

            import std.conv : to;

            auto labelText = (hourNum).to!dstring;
            return labelText;
        };
        scale.isOuterLabel = false;
        scale.minValue = 0;
        scale.maxValue = 59;
        scale.valueStep = 1.0;
        scale.majorTickStep = 5;
        return scale;
    }

    override void create()
    {
        super.create;

        handFactory = new MeterHandFactory;
        buildInitCreate(handFactory);

        auto progressStyle = createFillStyle;
        if (!progressStyle.isPreset && scale)
        {
            progressStyle.lineWidth = scale.tickMinorHeight;
        }

        progressBar = new RadialSegmentBar(diameter, 0, 360);
        progressBar.segmentsCount = 60;
        progressBar.segmentStyleOn = progressStyle;

        addCreate(progressBar);

        if (!hourHand && isCreateHourHand)
        {
            auto newHand = newHourHand;
            hourHand = !onNewHourHand ? newHand : onNewHourHand(newHand);

            if (onConfiguredHourHand)
            {
                onConfiguredHourHand(hourHand);
            }

            addCreate(hourHand);

            if (onCreatedHourHand)
            {
                onCreatedHourHand(hourHand);
            }
        }

        if (!minHand && isCreateMinHand)
        {
            auto newHand = newMinHand;
            minHand = !onNewMinHand ? newHand : onNewMinHand(newHand);

            if (onConfiguredMinHand)
            {
                onConfiguredMinHand(minHand);
            }

            addCreate(minHand);

            if (onCreatedMinHand)
            {
                onCreatedMinHand(minHand);
            }
        }

        if (!secHand && isCreateSecHand)
        {
            auto newHand = newSecHand;
            secHand = !onNewSecHand ? newHand : onNewSecHand(newHand);

            if (onConfiguredSecHand)
            {
                onConfiguredHourHand(secHand);
            }

            addCreate(secHand);

            if (onCreatedSecHand)
            {
                onCreatedSecHand(secHand);
            }
        }

        if (!handHolder && isCreateHandHolder)
        {
            auto newHolder = newHandHolder;
            handHolder = !onNewHandHolder ? newHolder : onNewHandHolder(newHolder);

            if (onConfiguredHandHolder)
            {
                onConfiguredHandHolder(handHolder);
            }

            addCreate(handHolder);

            import api.dm.kit.sprites2d.textures.texture2d : Texture2d;

            if (auto holderTexture = cast(Texture2d) handHolder)
            {
                holderTexture.bestScaleMode;
            }

            if (onCreatedHandHolder)
            {
                onCreatedHandHolder(handHolder);
            }
        }

        // version (DmAddon)
        // {
        //     import api.dm.gui.controls.containers.hbox : HBox;

        //     auto segmentLayout = new HBox(2);
        //     segmentLayout.margin.top = 20;
        //     addCreate(segmentLayout);

        //     enum sWidgh = 15;
        //     enum sHeight = 25;

        //     SevenSegment createSegment()
        //     {
        //         auto s = new class SevenSegment
        //         {
        //             this()
        //             {
        //                 super(sWidgh, sHeight);
        //             }

        //             override GraphicStyle createSegmentStyle()
        //             {
        //                 GraphicStyle style = createStyle;
        //                 style.isFill = true;
        //                 style.lineWidth = 2;
        //                 style.lineColor = theme.colorSecondary;
        //                 style.fillColor = theme.colorDanger;
        //                 return style;
        //             }
        //         };
        //         //s.isDrawBounds = true;
        //         s.hSegmentWidth = 8;
        //         s.hSegmentHeight = 3;
        //         s.vSegmentWidth = 3;
        //         s.vSegmentHeight = 8;
        //         s.segmentCornerBevel = 2;
        //         s.segmentSpacing = 2;
        //         return s;
        //     }

        //     hour1 = createSegment;
        //     hour2 = createSegment;

        //     segmentLayout.addCreate(hour1);
        //     segmentLayout.addCreate(hour2);

        //     segmentLayout.addCreate(new Text(":"));

        //     min1 = createSegment;
        //     min2 = createSegment;

        //     segmentLayout.addCreate(min1);
        //     segmentLayout.addCreate(min2);
        //     segmentLayout.addCreate(new Text(":"));

        //     sec1 = createSegment;
        //     sec2 = createSegment;

        //     segmentLayout.addCreate(sec1);
        //     segmentLayout.addCreate(sec2);

        // }

        if (!clockAnimation)
        {
            clockAnimation = new PauseTween2d(1000);
            clockAnimation.isInfinite = true;
            clockAnimation.onEnd ~= () { setTime; };
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

    import std.datetime.systime : Clock, SysTime;

    void setTime()
    {
        auto currTime = Clock.currTime;
        setTime(currTime);
    }

    void setTime(ref SysTime time)
    {
        setTime(time.hour, time.minute, time.second);
    }

    void setTime(ubyte hour, ubyte min, ubyte sec)
    {
        assert(hourHand);
        assert(minHand);
        assert(secHand);

        // version (DmAddon)
        // {
        //     if (hour >= 10)
        //     {
        //         hour1.show0to9(hour / 10);
        //         hour2.show0to9(hour % 10);
        //     }
        //     else
        //     {
        //         hour1.show0to9(0);
        //         hour2.show0to9(hour % 10);
        //     }

        //     if (min >= 10)
        //     {
        //         min1.show0to9(min / 10);
        //         min2.show0to9(min % 10);
        //     }
        //     else
        //     {
        //         min1.show0to9(0);
        //         min2.show0to9(min % 10);
        //     }

        //     if (sec >= 10)
        //     {
        //         sec1.show0to9(sec / 10);
        //         sec2.show0to9(sec % 10);
        //     }
        //     else
        //     {
        //         sec1.show0to9(0);
        //         sec2.show0to9(sec % 10);
        //     }
        // }

        if (progressBar)
        {
            assert(progressBar.segments.length == 60);

            if (sec == 0)
            {
                progressBar.hideSegments;
            }

            auto index = sec % progressBar.segments.length;

            if (isCheckFillSecs)
            {
                auto nextIndex = lastSecIndex + 1;
                if (nextIndex < index)
                {
                    foreach (i; nextIndex .. index)
                    {
                        progressBar.segments[i].isVisible = true;
                    }
                }
                else
                {
                    //TODO bounds
                    foreach (i; (index + 1) .. progressBar.segments.length)
                    {
                        progressBar.segments[i].isVisible = false;
                    }

                    foreach (i; 0 .. index)
                    {
                        progressBar.segments[i].isVisible = true;
                    }
                }
                isCheckFillSecs = false;
            }

            progressBar.segments[index].isVisible = true;

            lastSecIndex = index;
        }

        //assert(hour >= 1 && hour <= 12);

        // auto hourDeg = 30.0 * hour + min / 2.0; //converting current time
        // auto minDeg = 6.0 * min;
        // auto secDeg = 6.0 * sec;

        enum double minSecInHour = 60.0;
        enum double fullAngle = 360.0;

        const secDeg = ((sec / minSecInHour) * fullAngle);
        const minDeg = ((min / minSecInHour) * fullAngle) + ((sec / minSecInHour) * 6.0);
        const hourDeg = ((hour / 12.0) * fullAngle) + ((min / minSecInHour) * 30.0);

        hourHand.angle = hourDeg;
        minHand.angle = minDeg;
        secHand.angle = secDeg;
        handHolder.angle = secDeg;
    }
}
