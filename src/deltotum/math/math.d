module deltotum.math.math;

import math = std.math.trigonometry;
import mathConst = std.math.constants;
import mathCore = core.math;
import mathExp = std.math.exponential;
import deltotum.math.vector2d : Vector2d;

/**
 * Authors: initkfs
 */
class Math
{
    enum PI = mathConst.PI;

    //the a value and the b value should not change during the interpolation.
    static double lerp(double start, double end, double t, bool clamp = true) @nogc nothrow pure @safe
    {
        const double progressValue = clamp ? clamp01(t) : t;
        return start + (end - start) * progressValue;
    }

    static Vector2d lerp(Vector2d a, Vector2d b, float t, bool clamp = true) @nogc nothrow pure @safe
    {
        const double progress0to1 = clamp ? clamp01(t) : t;
        return Vector2d(a.x + (b.x - a.x) * progress0to1,
            a.y + (b.y - a.y) * progress0to1);
    }

    static double degToRad(double deg) @nogc nothrow pure @safe
    {
        return deg * (PI / 180.0);
    }

    static double radToDeg(double rad) @nogc nothrow pure @safe
    {
        return rad * (180 / PI);
    }

    static double clamp01(double value) @nogc nothrow pure @safe
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

    static double sinDeg(double valueDeg) @nogc nothrow pure @safe
    {
        return sin(degToRad(valueDeg));
    }

    static double cos(double value) @nogc nothrow pure @safe
    {
        return math.cos(value);
    }

    static double cosDeg(double valueDeg) @nogc nothrow pure @safe
    {
        return cos(degToRad(valueDeg));
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

    static double atan2(double y, double x) @nogc nothrow pure @safe
    {
        return math.atan2(y, x);
    }

    static T abs(T)(T value) @nogc nothrow pure @safe
    {
        import std.math.algebraic: Abs = abs;
        return Abs(value);
    }
}
