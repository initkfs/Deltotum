module api.dm.kit.tweens.curves.uni_interpolator;

import api.dm.kit.tweens.curves.interpolator : Interpolator;
import math = api.dm.math;

struct UniInterpolatorMethod {
    string name;
    float function(float) ptr;
}

/**
 * Authors: initkfs
 * Some interpolation functions have been ported from HaxeFlixel under https://opensource.org/licenses/MIT|MIT License. Copyrights: 2009, Adam 'Atomic' Saltsman; 2012, Matt Tuttle; 2013, HaxeFlixel Team
 */
class UniInterpolator : Interpolator
{
    private
    {
        enum PI2 = math.PI / 2;

        enum EL = 2 * math.PI / 0.45;
        enum B1 = 1 / 2.75;
        enum B2 = 2 / 2.75;
        enum B3 = 1.5 / 2.75;
        enum B4 = 2.5 / 2.75;
        enum B5 = 2.25 / 2.75;
        enum B6 = 2.625 / 2.75;
        enum ELASTIC_AMPLITUDE = 1.0;
        enum ELASTIC_PERIOD = 0.4;
    }

    this(){
        interpolateMethod = &linear;
    }

    static:

    UniInterpolatorMethod[] methodList() {
       //TODO appender;
       UniInterpolatorMethod[] methods;

       import std.traits: ReturnType;
       import std.conv: to;

       foreach (m; __traits(derivedMembers, typeof(this)))
        {
            alias func = __traits(getMember, typeof(this), m);
                //TODO best filter
                static if (__traits(isStaticFunction, func) && is(ReturnType!func : float))
                {
                    const funcName = __traits(identifier, func).to!string;
                    methods ~= UniInterpolatorMethod(funcName, &func);
                }
        }
        return methods;
    }

    //TODO more flexible way 
    UniInterpolator fromMethod(string methodName = "linear")()
    {
        auto interp = new UniInterpolator;
        interp.interpolateMethod = mixin(`&`, __traits(identifier, interp) ~ `.` ~ methodName);
        return interp;
    }

    float linear(float value)  nothrow
    {
        return value;
    }

    float flip(float value)  nothrow
    {
        return 1 - value;
    }

    float quadIn(float value)  nothrow
    {
        return value * value;
    }

    float quadOut(float value)  nothrow
    {
        return -value * (value - 2);
    }

    float quadInOut(float value)  nothrow
    {
        return value <= 0.5 ? value * value * 2 : 1 - (
            --value) * value * 2;
    }

    float cubeIn(float value)  nothrow
    {
        return value * value * value;
    }

    float cubeOut(float value)  nothrow
    {
        return 1 + (--value) * value * value;
    }

    float cubeInOut(float value)  nothrow
    {
        return value <= 0.5 ? value * value * value * 4 : 1 + (
            --value) * value * value * 4;
    }

    float quartIn(float value)  nothrow
    {
        return value * value * value * value;
    }

    float quartOut(float value)  nothrow
    {
        return 1 - (value -= 1) * value * value * value;
    }

    float quartInOut(float value)  nothrow
    {
        return value <= 0.5 ? value * value * value * value * 8 : (
            1 - (value = value * 2 - 2) * value * value * value) / 2 + 0.5;
    }

    float quintIn(float value)  nothrow
    {
        return value * value * value * value * value;
    }

    float quintOut(float value)  nothrow
    {
        return --value * value * value * value * value + 1;
    }

    float quintInOut(float value)  nothrow
    {
        return ((value *= 2) < 1) ? (
            value * value * value * value * value) / 2 : (
            (value -= 2) * value * value * value * value + 2) / 2;
    }

    float smoothStepIn(float value)  nothrow
    {
        return 2 * smoothStepInOut(value / 2);
    }

    float smoothStepOut(float value)  nothrow
    {
        return 2 * smoothStepInOut(value / 2 + 0.5) - 1;
    }

    float smoothStepInOut(float value)  nothrow
    {
        return value * value * (value * -2 + 3);
    }

    float smootherStepIn(float value)  nothrow
    {
        return 2 * smootherStepInOut(value / 2);
    }

    float smootherStepOut(float value)  nothrow
    {
        return 2 * smootherStepInOut(value / 2 + 0.5) - 1;
    }

    float smootherStepInOut(float value)  nothrow
    {
        return value * value * value * (
            value * (value * 6 - 15) + 10);
    }

    float sineIn(float value)  nothrow
    {
        return -math.cos(PI2 * value) + 1;
    }

    float sineOut(float value)  nothrow
    {
        return math.sin(PI2 * value);
    }

    float sineInOut(float value)  nothrow
    {
        return -math.cos(math.PI * value) / 2 + .5;
    }

    float bounceIn(float value)  nothrow
    {
        value = 1 - value;
        if (value < B1)
        {
            return 1 - 7.5625 * value * value;
        }

        if (value < B2)
        {
            return 1 - (7.5625 * (value - B3) * (value - B3) + 0.75);
        }

        if (value < B4)
        {
            return 1 - (7.5625 * (value - B5) * (value - B5) + 0.9375);
        }

        return 1 - (7.5625 * (value - B6) * (value - B6) + 0.984375);
    }

    float bounceOut(float value)  nothrow
    {
        if (value < B1)
        {
            return 7.5625 * value * value;
        }

        if (value < B2)
        {
            return 7.5625 * (value - B3) * (value - B3) + 0.75;
        }

        if (value < B4)
        {
            return 7.5625 * (value - B5) * (value - B5) + 0.9375;
        }

        return 7.5625 * (value - B6) * (value - B6) + 0.984375;
    }

    float bounceInOut(float value)  nothrow
    {
        if (value < 0.5)
        {
            value = 1 - value * 2;
            if (value < B1)
            {
                return (1 - 7.5625 * value * value) / 2;
            }

            if (value < B2)
            {
                return (1 - (7.5625 * (value - B3) * (value - B3) + 0.75)) / 2;
            }

            if (value < B4)
            {
                return (1 - (7.5625 * (value - B5) * (value - B5) + 0.9375)) / 2;
            }

            return (1 - (7.5625 * (value - B6) * (value - B6) + 0.984375)) / 2;
        }

        value = value * 2 - 1;

        if (value < B1)
        {
            return (7.5625 * value * value) / 2 + 0.5;
        }

        if (value < B2)
        {
            return (7.5625 * (value - B3) * (value - B3) + .75) / 2 + 0.5;
        }

        if (value < B4)
        {
            return (7.5625 * (value - B5) * (value - B5) + 0.9375) / 2 + 0.5;
        }

        return (7.5625 * (value - B6) * (value - B6) + 0.984375) / 2 + 0.5;
    }

    float circIn(float value)  nothrow
    {
        return -(math.sqrt(1 - value * value) - 1);
    }

    float circOut(float value)  nothrow
    {
        return math.sqrt(1 - (value - 1) * (value - 1));
    }

    float circInOut(float value)  nothrow
    {
        return value <= 0.5 ? (math.sqrt(1 - value * value * 4) - 1) / -2 : (
            math.sqrt(1 - (value * 2 - 2) * (value * 2 - 2)) + 1) / 2;
    }

    float expoIn(float value)  nothrow
    {
        return math.pow(2, 10 * (value - 1));
    }

    float expoOut(float value)  nothrow
    {
        return -math.pow(2, -10 * value) + 1;
    }

    float expoInOut(float value)  nothrow
    {
        return value < 0.5 ? math.pow(2, 10 * (value * 2 - 1)) / 2 : (
            -math.pow(2, -10 * (value * 2 - 1)) + 2) / 2;
    }

    float backIn(float value)  nothrow
    {
        return value * value * (2.70158 * value - 1.70158);
    }

    float backOut(float value)  nothrow
    {
        return 1 - (--value) * (value) * (-2.70158 * value - 1.70158);
    }

    float backInOut(float value)  nothrow
    {
        value *= 2;
        if (value < 1)
        {
            return value * value * (2.70158 * value - 1.70158) / 2;
        }

        value--;
        return (1 - (--value) * (value) * (-2.70158 * value - 1.70158)) / 2 + 0.5;
    }

    float elasticIn(float value)  nothrow
    {
        return -(ELASTIC_AMPLITUDE * math.pow(2,
                10 * (value -= 1)) * math.sin((value - (ELASTIC_PERIOD / (
                2 * math.PI) * math.asin(1 / ELASTIC_AMPLITUDE))) * (
                2 * math.PI) / ELASTIC_PERIOD));
    }

    float elasticOut(float value)  nothrow
    {
        return (ELASTIC_AMPLITUDE * math.pow(2,
                -10 * value) * math.sin((value - (ELASTIC_PERIOD / (
                2 * math.PI) * math.asin(1 / ELASTIC_AMPLITUDE))) * (
                2 * math.PI) / ELASTIC_PERIOD)
                + 1);
    }

    float elasticInOut(float value)  nothrow
    {
        if (value < 0.5)
        {
            return -0.5 * (math.pow(2, 10 * (value -= 0.5)) * math.sin(
                    (value - (ELASTIC_PERIOD / 4)) * (2 * math.PI) / ELASTIC_PERIOD));
        }
        return math.pow(2, -10 * (value -= 0.5)) * math.sin(
            (value - (ELASTIC_PERIOD / 4)) * (2 * math.PI) / ELASTIC_PERIOD) * 0.5 + 1;
    }

}
