module deltotum.core.maths.math;

import math = std.math.trigonometry;
import mathConst = std.math.constants;
import mathCore = core.math;
import mathExp = std.math.exponential;
import deltotum.core.maths.vector2d : Vector2d;

/**
 * Authors: initkfs
 */
enum PI = mathConst.PI;

//the a value and the b value should not change during the interpolation.
double lerp(double start, double end, double t, bool clamp = true) @nogc nothrow pure @safe
{
    const double progressValue = clamp ? clamp01(t) : t;
    return start + (end - start) * progressValue;
}

Vector2d lerp(Vector2d a, Vector2d b, float t, bool clamp = true) @nogc nothrow pure @safe
{
    const double progress0to1 = clamp ? clamp01(t) : t;
    return Vector2d(a.x + (b.x - a.x) * progress0to1,
        a.y + (b.y - a.y) * progress0to1);
}

double degToRad(double deg) @nogc nothrow pure @safe
{
    return deg * (PI / 180.0);
}

double radToDeg(double rad) @nogc nothrow pure @safe
{
    return rad * (180 / PI);
}

double clamp01(double value) @nogc nothrow pure @safe
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

double sin(double value) @nogc nothrow pure @safe
{
    return math.sin(value);
}

double sinDeg(double valueDeg) @nogc nothrow pure @safe
{
    return sin(degToRad(valueDeg));
}

double cos(double value) @nogc nothrow pure @safe
{
    return math.cos(value);
}

double cosDeg(double valueDeg) @nogc nothrow pure @safe
{
    return cos(degToRad(valueDeg));
}

double sqrt(double value) @nogc nothrow pure @safe
{
    return mathCore.sqrt(value);
}

double pow(double value, double base) @nogc nothrow pure @safe
{
    return mathExp.pow(value, base);
}

double asin(double value) @nogc nothrow pure @safe
{
    return math.asin(value);
}

double atan2(double y, double x) @nogc nothrow pure @safe
{
    return math.atan2(y, x);
}

T min(T)(T x, T y) @nogc nothrow pure @safe
{
    import std.algorithm.comparison : min;

    return min(x, y);
}

T max(T)(T x, T y) @nogc nothrow pure @safe
{
    import std.algorithm.comparison : max;

    return max(x, y);
}

T abs(T)(T value)
{
    import std.math.algebraic : Abs = abs;

    return Abs(value);
}

T factorial(T)(T n)
{
    return (n == 0 || n == 1) ? 1 : n * factorial(n - 1);
}
