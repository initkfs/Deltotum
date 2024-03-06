module dm.math.interps.uni_interpolator;

import dm.math.interps.interpolator : Interpolator;
import math = dm.math;

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
        enum ELASTIC_AMPLITUDE = 1;
        enum ELASTIC_PERIOD = 0.4;
    }

    static:

    //TODO more flexible way 
    UniInterpolator fromMethod(string methodName = "linear")()
    {
        auto interp = new UniInterpolator;
        interp.interpolateMethod = mixin(`&`, __traits(identifier, interp) ~ `.` ~ methodName);
        return interp;
    }

    double linear(double value) @nogc nothrow
    {
        return value;
    }

    double flip(double value) @nogc nothrow
    {
        return 1 - value;
    }

    double quadIn(double value) @nogc nothrow
    {
        return value * value;
    }

    double quadOut(double value) @nogc nothrow
    {
        return -value * (value - 2);
    }

    double quadInOut(double value) @nogc nothrow
    {
        return value <= 0.5 ? value * value * 2 : 1 - (
            --value) * value * 2;
    }

    double cubeIn(double value) @nogc nothrow
    {
        return value * value * value;
    }

    double cubeOut(double value) @nogc nothrow
    {
        return 1 + (--value) * value * value;
    }

    double cubeInOut(double value) @nogc nothrow
    {
        return value <= 0.5 ? value * value * value * 4 : 1 + (
            --value) * value * value * 4;
    }

    double quartIn(double value) @nogc nothrow
    {
        return value * value * value * value;
    }

    double quartOut(double value) @nogc nothrow
    {
        return 1 - (value -= 1) * value * value * value;
    }

    double quartInOut(double value) @nogc nothrow
    {
        return value <= 0.5 ? value * value * value * value * 8 : (
            1 - (value = value * 2 - 2) * value * value * value) / 2 + 0.5;
    }

    double quintIn(double value) @nogc nothrow
    {
        return value * value * value * value * value;
    }

    double quintOut(double value) @nogc nothrow
    {
        return --value * value * value * value * value + 1;
    }

    double quintInOut(double value) @nogc nothrow
    {
        return ((value *= 2) < 1) ? (
            value * value * value * value * value) / 2 : (
            (value -= 2) * value * value * value * value + 2) / 2;
    }

    double smoothStepIn(double value) @nogc nothrow
    {
        return 2 * smoothStepInOut(value / 2);
    }

    double smoothStepOut(double value) @nogc nothrow
    {
        return 2 * smoothStepInOut(value / 2 + 0.5) - 1;
    }

    double smoothStepInOut(double value) @nogc nothrow
    {
        return value * value * (value * -2 + 3);
    }

    double smootherStepIn(double value) @nogc nothrow
    {
        return 2 * smootherStepInOut(value / 2);
    }

    double smootherStepOut(double value) @nogc nothrow
    {
        return 2 * smootherStepInOut(value / 2 + 0.5) - 1;
    }

    double smootherStepInOut(double value) @nogc nothrow
    {
        return value * value * value * (
            value * (value * 6 - 15) + 10);
    }

    double sineIn(double value) @nogc nothrow
    {
        return -math.cos(PI2 * value) + 1;
    }

    double sineOut(double value) @nogc nothrow
    {
        return math.sin(PI2 * value);
    }

    double sineInOut(double value) @nogc nothrow
    {
        return -math.cos(math.PI * value) / 2 + .5;
    }

    double bounceIn(double value) @nogc nothrow
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

    double bounceOut(double value) @nogc nothrow
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

    double bounceInOut(double value) @nogc nothrow
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

    double circIn(double value) @nogc nothrow
    {
        return -(math.sqrt(1 - value * value) - 1);
    }

    double circOut(double value) @nogc nothrow
    {
        return math.sqrt(1 - (value - 1) * (value - 1));
    }

    double circInOut(double value) @nogc nothrow
    {
        return value <= 0.5 ? (math.sqrt(1 - value * value * 4) - 1) / -2 : (
            math.sqrt(1 - (value * 2 - 2) * (value * 2 - 2)) + 1) / 2;
    }

    double expoIn(double value) @nogc nothrow
    {
        return math.pow(2, 10 * (value - 1));
    }

    double expoOut(double value) @nogc nothrow
    {
        return -math.pow(2, -10 * value) + 1;
    }

    double expoInOut(double value) @nogc nothrow
    {
        return value < 0.5 ? math.pow(2, 10 * (value * 2 - 1)) / 2 : (
            -math.pow(2, -10 * (value * 2 - 1)) + 2) / 2;
    }

    double backIn(double value) @nogc nothrow
    {
        return value * value * (2.70158 * value - 1.70158);
    }

    double backOut(double value) @nogc nothrow
    {
        return 1 - (--value) * (value) * (-2.70158 * value - 1.70158);
    }

    double backInOut(double value) @nogc nothrow
    {
        value *= 2;
        if (value < 1)
        {
            return value * value * (2.70158 * value - 1.70158) / 2;
        }

        value--;
        return (1 - (--value) * (value) * (-2.70158 * value - 1.70158)) / 2 + 0.5;
    }

    double elasticIn(double value) @nogc nothrow
    {
        return -(ELASTIC_AMPLITUDE * math.pow(2,
                10 * (value -= 1)) * math.sin((value - (ELASTIC_PERIOD / (
                2 * math.PI) * math.asin(1 / ELASTIC_AMPLITUDE))) * (
                2 * math.PI) / ELASTIC_PERIOD));
    }

    double elasticOut(double value) @nogc nothrow
    {
        return (ELASTIC_AMPLITUDE * math.pow(2,
                -10 * value) * math.sin((value - (ELASTIC_PERIOD / (
                2 * math.PI) * math.asin(1 / ELASTIC_AMPLITUDE))) * (
                2 * math.PI) / ELASTIC_PERIOD)
                + 1);
    }

    double elasticInOut(double value) @nogc nothrow
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
