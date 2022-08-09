module deltotum.math.vector2d;

//TODO fast sqrt?
import std.math.algebraic : sqrt;
import std.math.operations : isClose;
import std.math.trigonometry : acos;
import std.math.constants : PI;

/**
 * Authors: initkfs
 */
//TODO template types, operator overloads
struct Vector2D
{
    double x = 0;
    double y = 0;

    Vector2D add(Vector2D other) const @nogc nothrow pure @safe
    {
        return Vector2D(x + other.x, y + other.y);
    }

    Vector2D subtract(Vector2D other) const @nogc nothrow pure @safe
    {
        return Vector2D(x - other.x, y - other.y);
    }

    Vector2D normalize() const @nogc nothrow pure @safe
    {
        const double length = magnitude;
        double normX = 0;
        double normY = 0;
        if (!isClose(length, 0.0))
        {
            normX = x / length;
            normY = y / length;
        }

        return Vector2D(normX, normY);
    }

    Vector2D clone() const @nogc nothrow pure @safe
    {
        return Vector2D(x, y);
    }

    double magnitude() const @nogc nothrow pure @safe
    {
        return magnitudeXY(x, y);
    }

    double magnitudeSquared() const @nogc nothrow pure @safe
    {
        return magnitudeSquaredXY(x, y);
    }

    double magnitudeSquaredXY(double x, double y) const @nogc nothrow pure @safe
    {
        return x * x + y * y;
    }

    double magnitudeXY(double x, double y) const @nogc nothrow pure @safe
    {
        return sqrt(magnitudeSquaredXY(x, y));
    }

    double distanceTo(Vector2D other) const @nogc nothrow pure @safe
    {
        const double deltaX = other.x - x;
        const double deltaY = other.y - y;
        return magnitudeXY(deltaX, deltaY);
    }

    //or multiply?
    Vector2D scale(double factor) const @nogc nothrow pure @safe
    {
        return Vector2D(x * factor, y * factor);
    }

    Vector2D inc(double value) const @nogc nothrow pure @safe
    {
        return Vector2D(x + value, y + value);
    }

    Vector2D inv() const @nogc nothrow pure @safe
    {
        return Vector2D(-x, -y);
    }

    Vector2D dec(double value) const @nogc nothrow pure @safe
    {
        return Vector2D(x - value, y - value);
    }

    Vector2D perpendicular() const @nogc nothrow pure @safe
    {
        //or y, -x to left
        return Vector2D(-y, x);
    }

    Vector2D translate(double tx, double ty) const @nogc nothrow pure @safe
    {
        return Vector2D(x + tx, y + ty);
    }

    Vector2D rotate(double angleDeg) const @nogc nothrow pure @safe
    {
        import deltotum.math.math : Math;

        immutable newX = x * Math.cosDeg(angleDeg) - y * Math.sinDeg(angleDeg);
        immutable newY = x * Math.sinDeg(angleDeg) + y * Math.cosDeg(angleDeg);
        return Vector2D(newX, newY);
    }

    Vector2D shear(double sx, double sy) const @nogc nothrow pure @safe
    {
        immutable newX = x + sx * y;
        immutable newY = y + sy * x;
        return Vector2D(newX, newY);
    }

    Vector2D project(double factor) const @nogc nothrow pure @safe
    {
        assert(!isClose(factor, 0.0));
        return Vector2D(x / factor, y / factor);
    }

    double dotProduct(Vector2D other) const @nogc nothrow pure @safe
    {
        return x * other.x + y * other.y;
    }

    double angleRad() const @nogc nothrow pure @safe
    {
        import deltotum.math.math : Math;

        immutable angle = Math.atan2(y, x);
        return angle;
    }

    double angleDeg() const @nogc nothrow pure @safe
    {
        import deltotum.math.math : Math;

        immutable anleDeg = Math.radToDeg(angleRad);
        return anleDeg;
    }

    double angleDegBetween(Vector2D other) const @nogc nothrow pure @safe
    {
        const double delta = (x * other.x + y * other.y) / sqrt(
            magnitudeSquaredXY(x, y) * magnitudeSquaredXY(other.x, other.y));

        if (delta > 1.0)
        {
            return 0;
        }
        if (delta < -1.0)
        {
            return 180;
        }
        //TODO angle utils
        const angleRad = acos(delta) * (180.0 / PI);
        return angleRad;
    }

    Vector2D polar(double angleDeg, double radius)
    {
        import deltotum.math.math : Math;

        immutable pX = radius * Math.cosDeg(angleDeg);
        immutable pY = radius * Math.sinDeg(angleDeg);
        return Vector2D(pX, pY);
    }

    string toString() immutable
    {
        import std.format : format;

        return format("x:%s,y:%s", x, y);
    }

}
