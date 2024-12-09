module api.dm.gui.controls.meters.gauges.radial_gauge;

import api.dm.gui.controls.meters.radial_min_value_meter : RadialMinValueMeter;
import api.dm.gui.controls.meters.scales.statics.rscale_static : RScaleStatic;
import api.dm.gui.controls.indicators.range_bars.radial_color_range_bar: RadialColorRangeBar;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.sprites.sprites2d.textures.texture2d : Texture2d;
import api.dm.gui.controls.texts.text : Text;
import api.dm.kit.sprites.sprites2d.tweens.tween2d : Tween2d;
import api.dm.kit.sprites.sprites2d.tweens.targets.value_tween2d : ValueTween2d;
import api.dm.kit.assets.fonts.font_size : FontSize;

import api.math.geom2.vec2 : Vec2d;
import api.math.geom2.rect2 : Rect2d;

import Math = api.math;

import std.conv : to;

debug import std.stdio : writeln, writefln;

import api.dm.kit.sprites.sprites2d.textures.vectors.shapes.vshape2d : VShape;

struct ZoneColor
{
    double percentTo = 0;
    RGBA color;
}

/**
 * Authors: initkfs
 */
class RadialGauge : RadialMinValueMeter!double
{

    RScaleStatic scale;
    bool isCreateScale = true;
    RScaleStatic delegate(RScaleStatic) onScaleCreate;
    void delegate(RScaleStatic) onScaleCreated;

    Sprite2d hand;

    bool isCreateHand = true;
    Sprite2d delegate(Sprite2d) onHandCreate;
    void delegate(Sprite2d) onHandCreated;

    Sprite2d handHolder;

    bool isCreateHandHolder = true;

    Sprite2d delegate(Sprite2d) onHandHolderCreate;
    void delegate(Sprite2d) onHandHolderCreated;

    ValueTween2d handTween;
    bool isCreateHandTween = true;
    ValueTween2d delegate(ValueTween2d) onHandTweenCreate;
    void delegate(ValueTween2d) onHandTweenCreated;

    Text label;

    bool isCreateLabel = true;
    Text delegate(Text) onLabelCreate;
    void delegate(Text) onLabelCreated;

    RadialColorRangeBar colorBar;

    protected
    {
        double _value;
    }

    this(double diameter = 0, double minAngleDeg = 0, double maxAngleDeg = 270, double minValue = 0, double maxValue = 1)
    {
        super(diameter, minValue, maxValue, minAngleDeg, maxAngleDeg);

        import api.dm.kit.sprites.sprites2d.layouts.center_layout : CenterLayout;

        this.layout = new CenterLayout;
        isDrawBounds = true;
    }

    override void loadTheme()
    {
        super.loadTheme;

        if (diameter == 0)
        {
            diameter = theme.meterThumbDiameter;
        }

        assert(diameter > 0);
        _width = diameter;
        _height = diameter;
    }

    Sprite2d newHand()
    {
        import api.dm.gui.controls.meters.hands.meter_hand_factory : MeterHandFactory;

        auto handStyle = createFillStyle;
        if (!handStyle.isPreset)
        {
            handStyle.fillColor = theme.colorDanger;
            handStyle.lineColor = theme.colorAccent;
        }

        import api.math.geom2.rect2 : Rect2d;

        auto handShapeSize = radius * 0.7;

        auto maxBounds = (Rect2d(0, 0, handShapeSize, handShapeSize)).boundingBoxMax;

        auto factory = new MeterHandFactory;
        buildInitCreate(factory);
        scope (exit)
        {
            factory.dispose;
        }

        auto hand = factory.createHand(maxBounds.width, maxBounds.height, 0, handStyle);
        return hand;
    }

    Sprite2d newHandHalder()
    {
        auto style = createFillStyle;
        auto holder = theme.regularPolyShape(10, 10, 0, style);
        return holder;
    }

    ValueTween2d newHandTween()
    {
        return new ValueTween2d(0, 0, 500);
    }

    Text newLabel()
    {
        return new Text("0");
    }

    RScaleStatic newScale()
    {
        auto scale = new RScaleStatic(diameter * 0.6, minAngleDeg, maxAngleDeg);
        scale.valueStep = 0.01;
        scale.majorTickStep = 5;
        return scale;
    }

    override void create()
    {
        super.create;

        if (!scale && isCreateScale)
        {
            auto s = newScale;
            scale = onScaleCreate ? onScaleCreate(s) : s;
            addCreate(scale);
            if (onScaleCreated)
            {
                onScaleCreated(scale);
            }
        }

        if (!hand && isCreateHand)
        {
            auto h = newHand;
            hand = onHandCreate ? onHandCreate(h) : h;
            addCreate(hand);
            if (onHandCreated)
            {
                onHandCreated(hand);
            }
        }

        if (!handHolder && isCreateHandHolder)
        {
            auto holder = newHandHalder;
            handHolder = onHandHolderCreate ? onHandHolderCreate(holder) : holder;
            addCreate(handHolder);
            if (onHandHolderCreated)
            {
                onHandHolderCreated(handHolder);
            }
        }

        if (!handTween && isCreateHandTween)
        {
            auto newTween = newHandTween;
            newTween.onOldNewValue ~= (oldValue, value) { handAngleDeg(value); };
            newTween.onStop ~= () { labelText(_value); };
            handTween = onHandTweenCreate ? onHandTweenCreate(newTween) : newTween;
            addCreate(handTween);
            if (onHandTweenCreated)
            {
                onHandTweenCreated(handTween);
            }
        }

        if (!label && isCreateLabel)
        {
            auto text = newLabel;

            text.isLayoutManaged = false;
            text.fontSize = FontSize.small;

            label = onLabelCreate ? onLabelCreate(text) : text;
            addCreate(label);
            if (onLabelCreated)
            {
                onLabelCreated(label);
            }
        }

        handAngleDeg(minAngleDeg);
        labelText(minValue);

        colorBar = new RadialColorRangeBar(radius * 0.7, 0, 360);
        addCreate(colorBar);
    }

    override void applyLayout()
    {
        super.applyLayout;

        label.x = boundsRect.middleX - label.boundsRect.halfWidth;
        label.y = boundsRect.middleY + label.boundsRect.height;
    }

    protected void handAngleDeg(double angleDeg)
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

    void labelText(double value)
    {
        label.text = value.to!dstring;
    }

    protected void handAngleDegAnim(double angleDeg)
    {
        if (handTween.isRunning)
        {
            //handAngleDeg(handTween.maxValue);
            handTween.stop;
        }

        auto oldAngle = hand.angle - 90;

        handTween.minValue = oldAngle;
        handTween.maxValue = angleDeg;
        handTween.run;
    }

    bool valueAngle(double angleDeg)
    {

        if (angleDeg < minAngleDeg || angleDeg > maxAngleDeg)
        {
            return false;
        }

        auto range = Math.abs(maxValue - minValue);
        auto angleRange = Math.abs(minAngleDeg - maxAngleDeg);
        auto value = angleDeg / (angleRange / range);
        handAngleDegAnim(angleDeg);
        _value = value;
        return true;
    }

    void value(double v)
    {
        double value = Math.clamp(v, minValue, maxValue);

        auto range = Math.abs(maxValue - minValue);
        auto angleRange = Math.abs(minAngleDeg - maxAngleDeg);

        auto angleOffset = value * (angleRange / range);

        auto newAngle = minAngleDeg + angleOffset;
        handAngleDegAnim(newAngle);
        _value = value;
    }
}
