module deltotum.math.umath;

import math = std.math.trigonometry;
import mathConst = std.math.constants;
import mathCore = core.math;
import mathExp = std.math.exponential;
import deltotum.math.vector2d : Vector2d;

/**
 * Authors: initkfs
 */
enum PI = mathConst.PI;
enum PI2 = PI * 2;

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

pragma(inline, true);
double sin(double value) @nogc nothrow pure @safe
{
    return math.sin(value);
}

pragma(inline, true);
double sinDeg(double valueDeg) @nogc nothrow pure @safe
{
    return sin(degToRad(valueDeg));
}

pragma(inline, true);
double cos(double value) @nogc nothrow pure @safe
{
    return math.cos(value);
}

pragma(inline, true);
double cosDeg(double valueDeg) @nogc nothrow pure @safe
{
    return cos(degToRad(valueDeg));
}

pragma(inline, true);
double sqrt(double value) @nogc nothrow pure @safe
{
    return mathCore.sqrt(value);
}

pragma(inline, true);
double pow(double value, double base) @nogc nothrow pure @safe
{
    return mathExp.pow(value, base);
}

pragma(inline, true);
double asin(double value) @nogc nothrow pure @safe
{
    return math.asin(value);
}

pragma(inline, true);
double atan2(double y, double x) @nogc nothrow pure @safe
{
    return math.atan2(y, x);
}

pragma(inline, true);
T min(T)(T x, T y) @nogc nothrow pure @safe
{
    import std.algorithm.comparison : min;

    return min(x, y);
}

pragma(inline, true);
T max(T)(T x, T y) @nogc nothrow pure @safe
{
    import std.algorithm.comparison : max;

    return max(x, y);
}

pragma(inline, true);
T abs(T)(T value)
{
    import std.math.algebraic : Abs = abs;

    return Abs(value);
}

T factorial(T)(T n)
{
    return (n == 0 || n == 1) ? 1 : n * factorial(n - 1);
}

double hypot(double a, double b) @nogc nothrow pure @safe
{
    double result = 0;
    if (abs(a) > abs(b))
    {
        result = b / a;
        result = abs(a) * sqrt(1 + result ^^ 2);
        return result;
    }

    if (b != 0.0)
    {
        result = a / b;
        result = abs(b) * sqrt(1 + result ^^ 2);
        return result;
    }

    return result;
}
