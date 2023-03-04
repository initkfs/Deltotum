module deltotum.core.maths.numericals.ode;

//TODO add relative error
double rungekutta4th(double x0, double y0, double x, double dx, double delegate(double, double) @safe dydx) @safe
in (x >= x0)
in (dx > 0)
{
    import std.math.rounding: round;

    immutable size_t stepSize = cast(size_t) round((x - x0) / dx);

    double k1, k2, k3, k4;

    double y = y0;
    double xx0 = x0;
    foreach (i; 0 .. stepSize)
    {
        k1 = dx * dydx(xx0, y);
        k2 = dx * dydx(xx0 + 0.5 * dx, y + 0.5 * k1);
        k3 = dx * dydx(xx0 + 0.5 * dx, y + 0.5 * k2);
        k4 = dx * dydx(xx0 + dx, y + k3);

        y = y + (1.0 / 6) * (k1 + 2 * k2 + 2 * k3 + k4);
        xx0 += dx;
    }

    return y;
}

unittest
{
    import std.math.operations : isClose;
    import std.format : format;

    //[0;1], y' = 3x^2y, y(0) = 1, h=0.05
    double x0 = 0, y0 = 1, h = 0.05;

    double[] results = [
        1, 1.0010004992, 1.0080320835, 1.0273677997, 1.0660923943, 1.1331484459,
        1.2411023627, 1.4091687088, 1.6686249048, 2.0730057545, 2.7182787121
    ];

    foreach (i; 0 .. 11)
    {
        auto x = x0 + 2 * h * i;
        auto res = rungekutta4th(x0, y0, x, h, (double x, double y) => 3 * (x ^^ 2) * y);
        assert(isClose(res, results[i]), format("Expected %s result %.10f, but received %.10f", i, results[i], res));
    }
}
