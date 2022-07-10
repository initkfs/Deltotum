module deltotum.math.math_util;

import math = std.math.trigonometry;
import mathConst = std.math.constants;
import mathCore = core.math;
import mathExp = std.math.exponential;

/**
 * Authors: initkfs
 */
class MathUtil
{
    enum PI = mathConst.PI;

    //the a value and the b value should not change during the interpolation.
    static double lerp(double start, double end, double t) @nogc nothrow pure @safe
    {
        return start + (end - start) * clamp1(t);
    }

    static double clamp1(double value) @nogc nothrow pure @safe
    {
        //TODO compare double
        if (value < 0)
        {
            return 0;
        }
        else if (value > 1)
        {
            return 1;
        }
        else
        {
            return value;
        }
    }

    static double sin(double value) @nogc nothrow pure @safe
    {
        return math.sin(value);
    }

    static double cos(double value) @nogc nothrow pure @safe
    {
        return math.cos(value);
    }

    static double sqrt(double value) @nogc nothrow pure @safe
    {
        return mathCore.sqrt(value);
    }

    static double pow(double value, double base) @nogc nothrow pure @safe
    {
        return mathExp.pow(value, base);
    }

    static double asin(double value) @nogc nothrow pure @safe
    {
        return math.asin(value);
    }
}
