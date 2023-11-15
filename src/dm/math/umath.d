module dm.math.umath;

import math = std.math.trigonometry;
import mathConst = std.math.constants;
import mathCore = core.math;
import mathExp = std.math.exponential;
import dm.math.vector2d : Vector2d;

/**
 * Authors: initkfs
 */
enum PI = mathConst.PI;
enum PI2 = PI * 2;
enum PIOver2 = mathConst.PI_2;
enum PIOver4 = mathConst.PI_4;

alias Tau = PI2;

//2.718281...
enum E = mathConst.E;
//0.434294...
enum Log10E = mathConst.LOG10E;
//1.442695...
enum Log2E = mathConst.LOG2E;

enum angleFullDeg = 360.0;
enum angleHalfDeg = 180.0;

double degToRad(double deg) @nogc nothrow pure @safe
{
    return deg * (PI / angleHalfDeg);
}

double radToDeg(double rad) @nogc nothrow pure @safe
{
    return rad * (angleHalfDeg / PI);
}

T clamp(T)(T value, T min, T max)
{
    if (value < min)
    {
        return min;
    }

    if (value > max)
    {
        return max;
    }
    return value;
}

double clamp01(double value) @nogc nothrow pure @safe
{
    return clamp(value, 0.0, 1.0);
}

T trunc(T)(T value) if (is(T : real))
{
    import std.math.rounding : trunc;

    //TODO other real?
    return trunc(value);
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
double sec(double value) @nogc nothrow pure @safe
{
    return 1.0 / cos(value);
}

pragma(inline, true);
double cosDeg(double valueDeg) @nogc nothrow pure @safe
{
    return cos(degToRad(valueDeg));
}

pragma(inline, true);
double tan(double valueRad) @nogc nothrow pure @safe
{
    return math.tan(valueRad);
}

pragma(inline, true);
double tanDeg(double valueDeg) @nogc nothrow pure @safe
{
    return math.tan(degToRad(valueDeg));
}

pragma(inline, true);
double tanHyp(double valueRad) @nogc nothrow pure @safe
{
    import std.math.trigonometry : tanh;

    return tanh(valueRad);
}

pragma(inline, true);
double cosHyp(double valueRad) @nogc nothrow pure @safe
{
    import std.math.trigonometry : cosh;

    return cosh(valueRad);
}

double ctg(double x)
{
    return 1 / tan(x);
}

double arcctg(double x)
{
    return PI / 2 - math.atan(x);
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

real round(real x) @nogc nothrow pure @safe
{
    import std.math.rounding : round;

    return round(x);
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

double sign(double value)
{
    import std.math.traits : sgn;

    return sgn(value);
}

bool isSameSign(double a, double b)
{
    import std.math.traits : sgn;

    return sign(a) == sign(b);
}

double toRange(double oldRangeValue, double oldMinInc, double oldMaxInc, double newMinInc, double newMaxInc)
{
    return (((oldRangeValue - oldMinInc) * (newMaxInc - newMinInc)) / (oldMaxInc - oldMinInc)) + newMinInc;
}
