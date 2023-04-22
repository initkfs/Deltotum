module deltotum.math.numericals.roots;

//f(x) = 0
double secant(in double x1, in double x2, in double delegate(double) @safe func, in double accuracy = double.epsilon) @safe
{
    import std.math.operations : isClose;
    import Math = deltotum.math.math;

    //without initialization root is NaN
    double mustBeRoot;
    double x11 = x1, x22 = x2;

    if (func(x11) * func(x22) < 0)
    {
        double rootDeviation;
        do
        {
            mustBeRoot = (x11 * func(x22) - x22 * func(x11)) / (func(x22) - func(x11));

            immutable double checkIsRoot = func(x11) * func(mustBeRoot);

            //update interval
            x11 = x22;
            x22 = mustBeRoot;

            if (isClose(checkIsRoot, 0.0, 0.0, double.epsilon))
            {
                break;
            }

            immutable double xm = (x11 * func(x22) - x22 * func(x11)) / (func(x22) - func(x11));
            rootDeviation = Math.abs(xm - mustBeRoot);
        }
        while (rootDeviation >= accuracy);

        return mustBeRoot;
    }

    return double.nan;
}

unittest
{
    import std.math.operations : isClose;

    auto root1 = secant(8, 3, (double x) => x ^^ 3 - 18 * x - 83, 0.001);
    assert(isClose(root1, 5.7043920434));
}

double regulafalsi(in double x1, in double x2, in double delegate(double) @safe func, size_t maxIterations = 100_000) @safe
{
    import std.math.operations : isClose;
    import std.math.operations: cmp;

    immutable double x1x2 = func(x1) * func(x2);
    if (cmp(x1x2, 0.0) >= 0)
    {
        return double.nan;
    }

    double x11 = x1, x22 = x2;
    double result = x11;

    foreach (i; 0 .. maxIterations)
    {
        result = (x11 * func(x22) - x22 * func(x11)) / (func(x22) - func(x11));

        immutable isRoot = isClose(func(result), 0.0, 0.0, double.epsilon);
        if (isRoot)
        {
            break;
        }
        else if (func(result) * func(x11) < 0)
        {
            x22 = result;
        }
        else
        {
            x11 = result;
        }
    }
    return result;
}

unittest
{
    import std.math.operations : isClose;

    auto root1 = regulafalsi(8, 3, (double x) => x ^^ 3 - 18 * x - 83);
    assert(isClose(root1, 5.7051157963));
}
