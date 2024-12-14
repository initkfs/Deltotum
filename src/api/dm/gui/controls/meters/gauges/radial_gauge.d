module api.dm.gui.controls.meters.gauges.radial_gauge;

import api.dm.gui.controls.meters.gauges.base_radial_gauge : BaseRadialGauge;
import api.dm.gui.controls.meters.scales.statics.rscale_static : RScaleStatic;
import api.dm.gui.controls.indicators.color_bars.radial_color_bar : RadialColorBar;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.texts.text : Text;
import api.dm.kit.sprites2d.tweens.tween2d : Tween2d;
import api.dm.kit.sprites2d.tweens.targets.value_tween2d : ValueTween2d;

import api.math.geom2.vec2 : Vec2d;
import api.math.geom2.rect2 : Rect2d;

import Math = api.math;

import std.conv : to;

debug import std.stdio : writeln, writefln;

/**
 * Authors: initkfs
 */
class RadialGauge : BaseRadialGauge
{
    Sprite2d hand;

    bool isCreateHand = true;
    Sprite2d delegate(Sprite2d) onNewHand;
    void delegate(Sprite2d) onCreatedHand;

    Sprite2d handHolder;

    bool isCreateHandHolder = true;

    Sprite2d delegate(Sprite2d) onNewHandHolder;
    void delegate(Sprite2d) onCreatedHandHolder;

    ValueTween2d handTween;
    bool isCreateHandTween = true;
    ValueTween2d delegate(ValueTween2d) onNewHandTween;
    void delegate(ValueTween2d) onCreatedHandTween;

    Text label;

    bool isCreateLabel = true;
    Text delegate(Text) onNewLabel;
    void delegate(Text) onCreatedLabel;

    RadialColorBar colorBar;

    bool isCreateColorBar = true;
    RadialColorBar delegate(RadialColorBar) onNewColorBar;
    void delegate(RadialColorBar) onCreatedColorBar;

    protected
    {
        double _value;
    }

    this(double diameter = 0, double minAngleDeg = 0, double maxAngleDeg = 180, double minValue = 0, double maxValue = 1)
    {
        super(diameter, minValue, maxValue, minAngleDeg, maxAngleDeg);
    }

    Sprite2d newHand()
    {
        import api.dm.gui.controls.meters.hands.meter_hand_factory : MeterHandFactory;

        auto handStyle = createHandStyle;

        auto handShapeHeight = radius;
        if(scale){
            handShapeHeight -= scale.tickMaxHeight;
            handShapeHeight *= 0.9;
        }
        auto handShapeWidth = theme.meterHandWidth;

        auto factory = new MeterHandFactory;
        buildInitCreate(factory);
        scope (exit)
        {
            factory.dispose;
        }

        import Math = api.math;
        auto coneHeight = handShapeWidth * Math.goldRounded; 
        auto hand = factory.createHand(handShapeWidth, handShapeHeight, handStyle, 0, coneHeight);
        return hand;
    }

    Sprite2d newHandHolder()
    {
        auto style = createFillStyle;
        auto size = radius * 0.2;
        auto holder = theme.regularPolyShape(size, 5, angle, style);
        return holder;
    }

    ValueTween2d newHandTween()
    {
        return new ValueTween2d(0, 0, 350);
    }

    Text newLabel()
    {
        return new Text("0");
    }

    RadialColorBar newColorBar()
    {
        return new RadialColorBar(diameter * 0.7, minAngleDeg, maxAngleDeg);
    }

    override void create()
    {
        super.create;

        assert(scale);

        if (!colorBar && isCreateColorBar)
        {
            auto newBar = newColorBar;
            colorBar = !onNewColorBar ? newBar : onNewColorBar(newBar);
            addCreate(colorBar);
            if (onCreatedColorBar)
            {
                onCreatedColorBar(colorBar);
            }
        }

        if (!hand && isCreateHand)
        {
            auto h = newHand;
            hand = onNewHand ? onNewHand(h) : h;
            addCreate(hand);
            if (onCreatedHand)
            {
                onCreatedHand(hand);
            }
        }

        if (!handHolder && isCreateHandHolder)
        {
            auto holder = newHandHolder;
            handHolder = onNewHandHolder ? onNewHandHolder(holder) : holder;
            addCreate(handHolder);
            if (onCreatedHandHolder)
            {
                onCreatedHandHolder(handHolder);
            }
        }

        if (!handTween && isCreateHandTween)
        {
            auto newTween = newHandTween;
            newTween.onOldNewValue ~= (oldValue, value) { handAngleDeg(value); };
            newTween.onStop ~= () { labelText(_value); };
            handTween = onNewHandTween ? onNewHandTween(newTween) : newTween;
            addCreate(handTween);
            if (onCreatedHandTween)
            {
                onCreatedHandTween(handTween);
            }
        }

        if (!label && isCreateLabel)
        {
            auto text = newLabel;

            text.setSmallSize;

            label = onNewLabel ? onNewLabel(text) : text;
            addCreate(label);

            if (onCreatedLabel)
            {
                onCreatedLabel(label);
            }
        }

        handAngleDeg(minAngleDeg);
        labelText(minValue);
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
