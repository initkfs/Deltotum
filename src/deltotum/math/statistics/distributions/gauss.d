module deltotum.math.statistics.distributions.gauss;

//https://en.wikipedia.org/wiki/Marsaglia_polar_method
double[] normal(size_t n)
{
    import std.math.operations : isClose, cmp;
    import deltotum.math.random : Random;
    import Math = deltotum.math.math;
    import std.math.exponential : log;

    auto rand = new Random;

    double[] values = [];
    immutable size_t m = n + n % 2;

    for (auto i = 0; i < m; i += 2)
    {
        double u, v, s;
        do
        {
            u = 2.0 * rand.randomBetween0to1 - 1.0;
            v = 2.0 * rand.randomBetween0to1 - 1.0;
            s = u * u + v * v;
        }
        //cmp(s, 1.0) >= 0
        while (s > 1 || isClose(s, 1.0) || isClose(s, 0.0, 0.0, double.epsilon));
        auto f = Math.sqrt(-2.0 * log(s) / s);
        values ~= u * f;
        values ~= v * f;
    }
    return values;
}

double pdf(double x) @safe
{
    import Math = deltotum.math.math;
    import std.math.exponential : exp;

    return exp(-x * x / 2) / Math.sqrt(2 * Math.PI);
}

//Probability density function 
double pdf(double x, double meanMu, double stddevSigma) @safe
{
    return pdf((x - meanMu) / stddevSigma) / stddevSigma;
}

//Cumulative distribution function
double cdf(double x) @safe
{
    import std.math.operations : isClose;

    enum minRange = -8.0, maxRange = 8.0;
    if (x < minRange)
    {
        return 0;
    }

    if (x > maxRange)
    {
        return 1.0;
    }

    import std.mathspecial : erfc;
    import Math = deltotum.math.math;

    return 0.5 * erfc(-x * Math.sqrt(0.5));
}

double cdf(double x, double meanMu, double stddevSigma) @safe
{
    return cdf((x - meanMu) / stddevSigma);
}

double inverseCDF(double x) @safe
{
    return inverseCDF(x, 0.00000001, -8, 8);
}

double inverseCDF(double x, double delta, double min, double max) @safe
{
    immutable double mid = min + (max - min) / 2;
    if (max - min < delta)
    {
        return mid;
    }

    immutable result = cdf(mid) > x ? inverseCDF(x, delta, min, mid) : inverseCDF(x, delta, mid, max);
    return result;
}

//PDF
unittest
{
    import std.math.operations : isClose;
    import Math = deltotum.math.math;

    auto pdf1 = pdf(2.6, 11.8, 4.2);
    assert(isClose(pdf1, 0.008624778229));
}

//CDF
unittest
{
    import std.math.operations : isClose;
    import Math = deltotum.math.math;

    auto cdf1 = cdf(2.6, 11.8, 4.2);
    assert(isClose(cdf1, 0.014244859855));
}
