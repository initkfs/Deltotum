module api.math.angle;

import math = std.math.trigonometry;
import mathConst = std.math.constants;
import mathCore = core.math;
import mathExp = std.math.exponential;
import api.math.vec2 : Vec2d;

/**
 * Authors: initkfs
 */
struct Angle
{
    const
    {
        int deg, minutes;
        double seconds = 0;
        bool isNegative;
    }

    this(int deg, int minutes = 0, double seconds = 0, bool isNegative = false) pure @safe
    {
        import std.exception : enforce;
        import std.conv : text;

        enforce(deg >= 0 && deg < 360, text(
                "The degree value must be equal to or greater than 0 and less than 360: ", deg));
        enforce(minutes >= 0 && minutes < 60, text(
                "The degree value must be equal to or greater than 0 and less than 60: ", minutes));

        import std.math.operations : cmp;

        enforce(cmp(seconds, 0.0) >= 0 && cmp(seconds, 60.0) < 0, text(
                "The seconds value must be equal to or greater than 0 and less than 60: ", seconds));

        this.deg = deg;
        this.minutes = minutes;
        this.seconds = seconds;
        this.isNegative = isNegative;
    }

    static Angle fromDecimal(double value) pure @safe
    {
        import Math = api.dm.math;
        import std.math.operations : cmp;

        const bool isNeg = cmp(value, 0.0) < 0;

        const double absValue = Math.abs(value);
        int degs = cast(int) absValue;
        const double minPart = (absValue - degs) * 60;
        int min = cast(int) minPart;
        double sec = ((minPart - min) * 60);

        Angle angle = Angle(degs, min, sec, isNeg);
        return angle;
    }

    double toDecimal() const nothrow pure @safe
    {
        import Math = api.dm.math;
        import std.math.operations : cmp;

        double result = Math.abs(deg) + (
            Math.abs(minutes) / 60.0) + (Math.abs(seconds) / 3600.0);
        if (isNegative)
        {
            return -result;
        }

        return result;
    }

    string toString() const
    {
        import std.format : format;

        return format("%s%d°%d'%.5f\"", isNegative ? "-" : "", deg, minutes, seconds);
    }
}

double toRange(double value, double range)
{
    import std.math.operations : cmp;

    double angle = value;
    while (cmp(0.0, angle) > 0)
    {
        angle += range;
    }
    //TODO epsilon?
    while (cmp(angle, range) >= 0)
    {
        angle -= range;
    }
    return angle;
}

unittest
{
    import std.math.operations : isClose;

    auto angle1 = Angle(10, 20, 30);
    assert(!angle1.isNegative);
    assert(angle1.deg == 10);
    assert(angle1.minutes == 20);
    assert(isClose(angle1.seconds, 30));

    assert(isClose(angle1.toDecimal, 10.341666666));

    auto angle2 = Angle.fromDecimal(10.341666666);
    assert(!angle2.isNegative);
    assert(angle2.deg == 10);
    assert(angle2.minutes == 20);
    assert(isClose(angle2.seconds, 30, 1e6));

    auto emptyAngle = Angle.fromDecimal(0);
    assert(!emptyAngle.isNegative);
    assert(emptyAngle.deg == 0);
    assert(emptyAngle.minutes == 0);
    assert(isClose(emptyAngle.seconds, 0.0, 0.0, 1e6));
    assert(isClose(emptyAngle.toDecimal, 0.0, 0.0, 1e6));

    auto negAngle = Angle.fromDecimal(-10);
    assert(negAngle.isNegative);
}
