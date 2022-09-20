module deltotum.math.vector2d;

//TODO fast sqrt?
import std.math.algebraic : sqrt;
import std.math.operations : isClose;
import std.math.trigonometry : acos;
import std.math.constants : PI;
import deltotum.math.matrices.matrix : Matrix2x2, Matrix2x1;

/**
 * Authors: initkfs
 */
//TODO template types, operator overloads
struct Vector2d
{
    double x = 0;
    double y = 0;

    Vector2d add(Vector2d other) const @nogc nothrow pure @safe
    {
        return Vector2d(x + other.x, y + other.y);
    }

    Vector2d subtract(Vector2d other) const @nogc nothrow pure @safe
    {
        return Vector2d(x - other.x, y - other.y);
    }

    Vector2d normalize() const @nogc nothrow pure @safe
    {
        const double length = magnitude;
        double normX = 0;
        double normY = 0;
        if (!isClose(length, 0.0))
        {
            normX = x / length;
            normY = y / length;
        }

        return Vector2d(normX, normY);
    }

    Vector2d clone() const @nogc nothrow pure @safe
    {
        return Vector2d(x, y);
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

    double distanceTo(Vector2d other) const @nogc nothrow pure @safe
    {
        const double deltaX = other.x - x;
        const double deltaY = other.y - y;
        return magnitudeXY(deltaX, deltaY);
    }

    //or multiply?
    Vector2d scale(double factor) const @nogc nothrow pure @safe
    {
        return Vector2d(x * factor, y * factor);
    }

    Vector2d inc(double value) const @nogc nothrow pure @safe
    {
        return Vector2d(x + value, y + value);
    }

    Vector2d inv() const @nogc nothrow pure @safe
    {
        return Vector2d(-x, -y);
    }

    Vector2d dec(double value) const @nogc nothrow pure @safe
    {
        return Vector2d(x - value, y - value);
    }

    Vector2d perpendicular() const @nogc nothrow pure @safe
    {
        //or y, -x to left
        return Vector2d(-y, x);
    }

    Vector2d translate(double tx, double ty) const @nogc nothrow pure @safe
    {
        return Vector2d(x + tx, y + ty);
    }

    Vector2d rotate(double angleDeg) const @nogc nothrow pure @safe
    {
        import deltotum.math.math : Math;

        immutable newX = x * Math.cosDeg(angleDeg) - y * Math.sinDeg(angleDeg);
        immutable newY = x * Math.sinDeg(angleDeg) + y * Math.cosDeg(angleDeg);
        return Vector2d(newX, newY);
    }

    Vector2d shear(double sx, double sy) const @nogc nothrow pure @safe
    {
        immutable newX = x + sx * y;
        immutable newY = y + sy * x;
        return Vector2d(newX, newY);
    }

    Vector2d project(double factor) const @nogc nothrow pure @safe
    {
        assert(!isClose(factor, 0.0));
        return Vector2d(x / factor, y / factor);
    }

    double dotProduct(Vector2d other) const @nogc nothrow pure @safe
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

    double angleDegBetween(Vector2d other) const @nogc nothrow pure @safe
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

    Vector2d polar(double angleDeg, double radius) const @nogc nothrow pure @safe
    {
        import deltotum.math.math : Math;

        immutable pX = radius * Math.cosDeg(angleDeg);
        immutable pY = radius * Math.sinDeg(angleDeg);
        return Vector2d(pX, pY);
    }

    Matrix2x1 transpose() const pure @safe
    {
        return Matrix2x1([[x], [y]]);
    }

    Vector2d linoperator(Matrix2x2 linearOpMatrix) const pure @safe
    {
        Matrix2x1 result = linearOpMatrix.multiply(transpose);
        return Vector2d(result.value(0, 0), result.value(1, 0));
    }

    string toString() const
    {
        import std.format : format;

        return format("x:%s,y:%s", x, y);
    }

    unittest
    {

        Vector2d v1 = Vector2d(2, 1);

        Vector2d horizontalReflect = v1.linoperator(Matrix2x2([[-1, 0], [0, 1]]));
        assert(horizontalReflect.x == -2);
        assert(horizontalReflect.y == 1);

    }

}
