module dm.math.numericals.interp;

/**
 * Authors: initkfs
 */
import dm.math.vector2 : Vector2;
import dm.math : clamp01;

import std.math.traits : isFinite;

double lagrange(in double x, in double[] xValues, in double[] yValues) @nogc pure @safe nothrow
in (xValues.length >= 2)
in (xValues.length == yValues.length)
out (result; isFinite(result))
{
    if (xValues.length != yValues.length)
    {
        return double.nan;
    }

    if (xValues.length < 2)
    {
        return double.nan;
    }

    import std.algorithm.searching : maxElement;

    if (x > xValues.maxElement)
    {
        return double.nan;
    }

    double result = 0;
    immutable pointsCount = xValues.length;

    foreach (i; 0 .. pointsCount)
    {
        double polynomsProduct = 1;
        foreach (j; 0 .. pointsCount)
        {
            if (j != i)
            {
                //x - xj / xi - xj
                polynomsProduct *= (x - xValues[j]) / (xValues[i] - xValues[j]);
            }
        }
        //yi * li(x)
        result += yValues[i] * polynomsProduct;
    }

    return result;
}

unittest
{
    import std.math.operations : isClose;

    auto xValues = [0.0, 1, 2, 5];
    auto yValues = [2.0, 3, 12, 147];
    double result1 = lagrange(3, xValues, yValues);
    assert(isClose(result1, 35));
}

//the start value and the end value should not change during the interpolation.
double lerp(double start, double end, double t, bool clamp = true) @nogc nothrow pure @safe
{
    immutable progressValue = clamp ? clamp01(t) : t;
    return start + (end - start) * progressValue;
}

//https://stackoverflow.com/questions/4353525/floating-point-linear-interpolation
T lerpPrec(T)(T start, T end, T t)
{
    immutable progressValue = clamp01(t);
    return ((1 - t) * start) + (end * progressValue);
}

/** 
 * Smooth cubic interpolation.
 * Ported from MonoGame under MIT license, https://opensource.org/license/mit 
 * see https://stackoverflow.com/questions/590462/xna-mathhelper-smoothstep-how-does-it-work
 * auto speed = serp(0, destSpeed, f/destSpeed);
 */
double serp(double start, double end, double t0to1)
{
    immutable result = hermite(start, 0.0, end, 0.0, t0to1);
    return result;
}

double blerp(double c00, double c10, double c01, double c11, double tx, double ty, bool clamp = true)
{
    return lerp(lerp(c00, c10, tx, clamp), lerp(c01, c11, tx, clamp), ty);
}

Vector2 lerp(Vector2 a, Vector2 b, double t, bool clamp = true) @nogc nothrow pure @safe
{
    const double progress0to1 = clamp ? clamp01(t) : t;
    return Vector2(a.x + (b.x - a.x) * progress0to1,
        a.y + (b.y - a.y) * progress0to1);
}

/** 
 * Catmull-Rom spline interpolation
 * Ported from http://www.mvps.org/directx/articles/catmull/
 */
double catmullRom(double p0, double p1, double p2, double p3, double t)
{
    immutable tSqr = t * t;
    immutable tCub = tSqr * t;
    immutable result = (0.5 * (2.0 * p1 + (p2 - p0) * t + (
            2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * tSqr + (
            3.0 * p1 - p0 - 3.0 * p2 + p3) * tCub));
    return result;
}

/** 
 * Hermite spline interpolation.
 * Ported from MonoGame under MIT license, https://opensource.org/license/mit 
 */
double hermite(double p1, double tangent1, double p2, double tangent2, double t)
{
    immutable typeof(return) v1 = p1, v2 = p2, t1 = tangent1, t2 = tangent2, s = t;
    immutable sSquared = s * s;
    immutable sCubed = sSquared * s;

    typeof(return) result;
    //rough comparisons of floating numbers for speedup
    if (t == 0)
    {
        result = p1;
    }
    else if (t == 1)
    {
        result = p2;
    }
    else
    {
        result = (2 * v1 - 2 * v2 + t2 + t1) * sCubed +
            (
                3 * v2 - 3 * v1 - 2 * t1 - t2) * sSquared +
            t1 * s + v1;
    }

    return result;
}
