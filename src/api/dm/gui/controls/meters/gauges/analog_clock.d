module api.dm.gui.controls.meters.gauges.analog_clock;

import api.dm.gui.controls.meters.radial_min_value_meter : RadialMinValueMeter;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.meters.hands.meter_hand_factory : MeterHandFactory;

import api.dm.kit.sprites.sprites2d.tweens.pause_tween2d : PauseTween2d;
import api.dm.kit.sprites.sprites2d.tweens.tween2d : Tween2d;
import api.dm.gui.controls.meters.scales.statics.rscale_static : RScaleStatic;

import api.dm.gui.containers.circle_box : CircleBox;
import api.dm.gui.controls.texts.text : Text;
import api.dm.kit.assets.fonts.font_size : FontSize;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.geom2.vec2 : Vec2d;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites.sprites2d.textures.vectors.shapes.vcircle : VCircle;
import api.dm.kit.sprites.sprites2d.textures.vectors.shapes.varc : VArc;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites.sprites2d.textures.vectors.shapes.vregular_polygon : VRegularPolygon;
import api.dm.kit.sprites.sprites2d.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;
import api.dm.kit.sprites.sprites2d.textures.vectors.shapes.vshape2d : VShape;
import api.dm.kit.sprites.sprites2d.tweens.pause_tween2d : PauseTween2d;
import api.dm.kit.sprites.sprites2d.textures.texture2d : Texture2d;
import api.math.geom2.rect2 : Rect2d;
import Math = api.dm.math;

debug import std.stdio : writeln, writefln;

import std.conv : to;

/**
 * Authors: initkfs
 */
class AnalogClock : RadialMinValueMeter!double
{

    RScaleStatic clockScale;
    bool isCreateClockScale = true;
    RScaleStatic delegate(RScaleStatic) onClockScaleCreate;
    void delegate(RScaleStatic) onClockScaleCreated;

    Sprite2d hourHand;
    bool isCreateHourHand = true;
    Sprite2d delegate(Sprite2d) onHourHandCreate;
    void delegate(Sprite2d) onHourHandCreated;

    Sprite2d minHand;
    bool isCreateMinHand = true;
    Sprite2d delegate(Sprite2d) onMinHandCreate;
    void delegate(Sprite2d) onMinHandCreated;

    Sprite2d secHand;
    bool isCreateSecHand = true;
    Sprite2d delegate(Sprite2d) onSecHandCreate;
    void delegate(Sprite2d) onSecHandCreated;

    Sprite2d handHolder;
    bool isCreateHandHolder = true;
    Sprite2d delegate(Sprite2d) onHandHolderCreate;
    void delegate(Sprite2d) onHandHolderCreated;

    Tween2d clockAnimation;
    bool isCreateClockAnimation = true;
    Tween2d delegate(Tween2d) onClockAnimationCreate;
    void delegate(Tween2d) onClockAnimationCreated;

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

        import api.dm.kit.sprites.sprites2d.layouts.center_layout : CenterLayout;

        this.layout = new CenterLayout;
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadAnalogClockTheme;
    }

    void loadAnalogClockTheme()
    {
        if (_diameter == 0)
        {
            _diameter = theme.meterThumbDiameter;
            _radius = _diameter / 2;
        }

        assert(_diameter > 0);
        _width = _diameter;
        _height = _diameter;
    }

    Sprite2d newHourHand()
    {
        assert(handFactory);

        auto handHeight = diameter * 0.4;

        auto handStyle = createHandStyle;
        if (!handStyle.isPreset)
        {
            handStyle.fillColor = theme.colorWarning;
        }

        auto handBox = handBoundingBox(handHeight);
        auto newHand = handFactory.createHand(handBox.width, handBox.height, 0, handStyle);
        return newHand;
    }

    Sprite2d newMinHand()
    {
        assert(handFactory);

        auto handHeight = diameter * 0.5;
        auto handStyle = createHandStyle;

        if (!handStyle.isPreset)
        {
            handStyle.fillColor = theme.colorWarning;
        }

        auto handBox = handBoundingBox(handHeight);
        auto newHand = handFactory.createHand(handBox.width, handBox.height, 0, handStyle);
        return newHand;
    }

    Sprite2d newSecHand()
    {
        assert(handFactory);

        auto handHeight = diameter * 0.5;
        auto handStyle = createHandStyle;
        if (!handStyle.isPreset)
        {
            handStyle.fillColor = theme.colorDanger;
            handStyle.lineColor = theme.colorDanger;
        }

        auto handBox = handBoundingBox(handHeight);
        auto newHand = handFactory.createHand(handBox.width, handBox.height, 0, handStyle);
        newHand.isDrawCenterBounds = true;
        newHand.boundsCenterColor = RGBA.green;
        return newHand;
    }

    Tween2d newClockAnimation()
    {
        return new PauseTween2d(1000);
    }

    Sprite2d newHandHolder()
    {
        auto style = createFillStyle;
        if(!style.isPreset){
            style.fillColor = theme.colorDanger;
            style.lineColor = theme.colorDanger;
        }

        auto size = radius * 0.2;
        return theme.regularPolyShape(size, 6, angle, style);
    }

    RScaleStatic newClockScale()
    {
        auto size = diameter;
        auto scale = new RScaleStatic(size, minAngleDeg, maxAngleDeg);
        scale.isLastTickMajorTick = false;
        scale.isDrawCenterBounds = true;
        scale.onVTickIsContinue = (ctx, Rect2d tickBounds, bool isMajorTick){
            auto style = createFillStyle;
            ctx.color = style.fillColor;

            if(!style.isPreset && isMajorTick){
                ctx.color = theme.colorDanger;
            }

            auto tickRadius = isMajorTick ? scale.tickMajorHeight / 2 : scale.tickMinorHeight /2;
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

        if (!clockScale && isCreateClockScale)
        {
            auto newScale = newClockScale;
            clockScale = !onClockScaleCreate ? newScale : onClockScaleCreate(newScale);
            addCreate(newScale);
            if (onClockScaleCreated)
            {
                onClockScaleCreated(newScale);
            }
        }

        if (!hourHand && isCreateHourHand)
        {
            auto newHand = newHourHand;
            hourHand = !onHourHandCreate ? newHand : onHourHandCreate(newHand);
            addCreate(hourHand);
            if (onHourHandCreated)
            {
                onHourHandCreated(hourHand);
            }
        }

        if (!minHand && isCreateMinHand)
        {
            auto newHand = newMinHand;
            minHand = !onMinHandCreate ? newHand : onMinHandCreate(newHand);
            addCreate(minHand);
            if (onMinHandCreated)
            {
                onMinHandCreated(minHand);
            }
        }

        if (!secHand && isCreateSecHand)
        {
            auto newHand = newSecHand;
            secHand = !onSecHandCreate ? newHand : onSecHandCreate(newHand);
            addCreate(secHand);
            if (onSecHandCreated)
            {
                onSecHandCreated(secHand);
            }
        }

        if (!handHolder && isCreateHandHolder)
        {
            auto newHolder = newHandHolder;
            handHolder = !onHandHolderCreate ? newHolder : onHandHolderCreate(newHolder);
            addCreate(handHolder);
            
            if(auto holderTexture = cast(Texture2d) handHolder){
                holderTexture.bestScaleMode;
            }
            
            if (onHandHolderCreated)
            {
                onHandHolderCreated(handHolder);
            }
        }

        const ticksCount = 60;
        const angleOffset = 360.0 / ticksCount;
        //Texture2d proto = ((i % 5) == 0) ? majorTickProto : minorTickProto;

        // size_t hourNum = (i / 5 + 3) % 12;
        // if (hourNum == 0)
        // {
        //     hourNum = 12;
        // }

        //auto labelText = (hourNum).to!dstring;

        //double endAngle = 360;

        // addCreate(centerShape);

        // auto hourStyle = GraphicStyle(3, theme.colorAccent, true, theme.colorWarning);

        // hourHand = new Hand(width, height, 6, 55, hourStyle);
        // addCreate(hourHand);

        // auto minStyle = hourStyle;

        // minHand = new Hand(width, height, 6, 70, minStyle);
        // addCreate(minHand);

        // auto secStyle = GraphicStyle(1, theme.colorDanger, true, theme.colorDanger);

        // secHand = new Hand(width, height, 5, 75, secStyle);
        // addCreate(secHand);

        // VRegularPolygon holder = new VRegularPolygon(15, GraphicStyle(0, theme.colorDanger, true, theme
        //         .colorDanger));
        // addCreate(holder);
        // handHolder = holder;

        // version (DmAddon)
        // {
        //     import api.dm.gui.containers.hbox : HBox;

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

        // assert(secIndicatorSegments.length == 60);

        // if (sec == 0)
        // {
        //     foreach (Sprite2d s; secIndicatorSegments)
        //     {
        //         s.isVisible = false;
        //     }
        // }

        // auto index = sec % secIndicatorSegments.length;
        // if (sec == 0)
        // {
        //     index = secIndicatorSegments.length - 1;
        // }
        // else
        // {
        //     index--;
        // }

        // if (isCheckFillSecs)
        // {
        //     auto nextIndex = lastSecIndex + 1;
        //     if (nextIndex < index)
        //     {
        //         foreach (i; nextIndex .. index)
        //         {
        //             secIndicatorSegments[i].isVisible = true;
        //         }
        //     }
        //     else
        //     {
        //         //TODO bounds
        //         foreach (i; (index + 1) .. secIndicatorSegments.length)
        //         {
        //             secIndicatorSegments[i].isVisible = false;
        //         }

        //         foreach (i; 0 .. index)
        //         {
        //             secIndicatorSegments[i].isVisible = true;
        //         }
        //     }
        //     isCheckFillSecs = false;
        // }

        // secIndicatorSegments[index].isVisible = true;

        // lastSecIndex = index;

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
