module deltotum.core.maths.numericals.interp;

/**
 * Authors: initkfs
 */
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
