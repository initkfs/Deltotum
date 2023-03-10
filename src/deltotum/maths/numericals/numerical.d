module deltotum.maths.numericals.numerical;
/**
 * Authors: initkfs
 */

/** 
 * 
 * lim Δx->0 (f(x0 + Δx) - f(x0)) / Δx
 */
double delegate(double) derivative(double delegate(double) f, double deltaX = 0.000001)
in (deltaX > 0)
{
    auto derFunc = (double x0) => (f(x0 + deltaX) - f(x0)) / deltaX;
    return derFunc;
}

unittest
{
    import std.math.operations : isClose;

    double delegate(double) x3 = (x) => x ^^ 3;
    auto derx3 = (double x) => 3 * x ^^ 2;
    auto derx3Result = derivative(x3);

    foreach (i; 1 .. 5)
    {
        auto res1 = derx3Result(i);
        auto res2 = derx3(i);
        if (!isClose(res1, res2, 0.000001))
        {
            import std.conv : text;

            assert(false, text(i, ":", res1, ":", res2));
        }
    }
}
