module api.dm.gui.controls.meters.clocks.analogs.faces.analog_clock_face;

import api.dm.gui.controls.meters.gauges.base_radial_gauge : BaseRadialGauge;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.meters.hands.meter_hand_factory : MeterHandFactory;
import api.dm.gui.controls.indicators.segmentbars.radial_segmentbar : RadialSegmentBar;

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
class AnalogClockFace : BaseRadialGauge
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

    float handWidth = 0;

    protected
    {
        bool isCheckFillSecs;
        size_t lastSecIndex;

        MeterHandFactory handFactory;
    }

    this(float diameter = 0)
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

    protected Vec2d handCone(float size)
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
        scale.labelTextProvider = (size_t labelIndex, size_t tickIndex, Vec2d pos, bool isMajorTick, float offsetTick) {
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
    }

    override void pause()
    {
        super.pause;
        isCheckFillSecs = true;
    }

    bool setTime(ubyte hour, ubyte min, ubyte sec)
    {
        assert(hourHand);
        assert(minHand);
        assert(secHand);

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

        enum float minSecInHour = 60.0;
        enum float fullAngle = 360.0;

        const secDeg = ((sec / minSecInHour) * fullAngle);
        const minDeg = ((min / minSecInHour) * fullAngle) + ((sec / minSecInHour) * 6.0);
        const hourDeg = ((hour / 12.0) * fullAngle) + ((min / minSecInHour) * 30.0);

        hourHand.angle = hourDeg;
        minHand.angle = minDeg;
        secHand.angle = secDeg;
        handHolder.angle = secDeg;

        return true;
    }
}
