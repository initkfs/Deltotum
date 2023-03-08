module deltotum.core.maths.numericals.integration;

double trapezoidal(double min, double max, size_t n, double delegate(double) @safe f) @safe
in (min < max)
in (n > 0)
{
    import std.math.operations : cmp;

    if (cmp(min, max) >= 0 || n == 0)
    {
        return double.nan;
    }

    immutable double stepSize = (max - min) / n;
    double result = (f(min) + f(max)) / 2; //trapezoid area
    foreach (i; 1 .. n)
    {
        double x = min + stepSize * i;
        result += f(x);
    }
    return result * stepSize;
}

unittest
{
    import std.math.operations : isClose;

    double result1 = trapezoidal(0, 1, 5, (x) => 1 / (1 + (x ^^ 2)));
    assert(isClose(result1, 0.7837315285));
}

double simpsons(double min, double max, size_t n, double delegate(double) @safe f) @safe
in (min < max)
in (n >= 2)
in (n % 2 == 0)
{
    import std.math.operations : isClose;

    if (isClose(min, max))
    {
        return double.nan;
    }

    if (min > max)
    {
        return double.nan;
    }

    if (n < 2 || n % 2 != 0)
    {
        return double.nan;
    }

    double result = 0;

    immutable double stepSize = (max - min) / (n - 1);

    //4/3 rule
    for (size_t i = 1; i < n - 1; i += 2)
    {
        result += 4.0 / 3 * f(min + stepSize * i);
    }

    // 2/3 rule
    for (size_t i = 2; i < n - 1; i += 2)
    {
        result += 2.0 / 3 * f(min + stepSize * i);
    }

    // 1/3 rule
    result += 1.0 / 3 * (f(min) + f(max));

    return result * stepSize;
}

unittest
{
    import std.math.operations : isClose;

    double result1 = simpsons(0, 1, 10, (x) => 1 / (1 + x * x));
    assert(isClose(result1, 0.7658508588));
}
