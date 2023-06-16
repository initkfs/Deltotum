module deltotum.math.numericals.interp;

/**
 * Authors: initkfs
 */
import deltotum.math.vector2d : Vector2d;
import deltotum.math : clamp01;

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
    const double progressValue = clamp ? clamp01(t) : t;
    return start + (end - start) * progressValue;
}

double blerp(double c00, double c10, double c01, double c11, double tx, double ty, bool clamp = true)
{
    return lerp(lerp(c00, c10, tx, clamp), lerp(c01, c11, tx, clamp), ty);
}

Vector2d lerp(Vector2d a, Vector2d b, float t, bool clamp = true) @nogc nothrow pure @safe
{
    const double progress0to1 = clamp ? clamp01(t) : t;
    return Vector2d(a.x + (b.x - a.x) * progress0to1,
        a.y + (b.y - a.y) * progress0to1);
}
