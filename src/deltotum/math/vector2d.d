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
        if (length != 0)
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

    Vector2d scale(double factor) const @nogc nothrow pure @safe
    {
        return Vector2d(x * factor, y * factor);
    }

    Vector2d multiply(Vector2d other) const @nogc nothrow pure @safe
    {
        return Vector2d(x * other.x, y * other.y);
    }

    Vector2d div(double factor) const @nogc nothrow pure @safe
    {
        assert(factor != 0);
        const newX = x / factor;
        const newY = y / factor;
        return Vector2d(newX, newY);
    }

    Vector2d inc(double value) const @nogc nothrow pure @safe
    {
        return Vector2d(x + value, y + value);
    }

    Vector2d incXY(double xValue, double yValud) const @nogc nothrow pure @safe
    {
        return Vector2d(x + xValue, y + yValud);
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
        import math = deltotum.math;

        immutable newX = x * math.cosDeg(angleDeg) - y * math.sinDeg(angleDeg);
        immutable newY = x * math.sinDeg(angleDeg) + y * math.cosDeg(angleDeg);
        return Vector2d(newX, newY);
    }

    Vector2d shear(double sx, double sy) const @nogc nothrow pure @safe
    {
        immutable newX = x + sx * y;
        immutable newY = y + sy * x;
        return Vector2d(newX, newY);
    }

    Vector2d project(double factor) const @nogc nothrow pure @safe
    in (factor != 0.0)
    {
        return Vector2d(x / factor, y / factor);
    }

    double dotProduct(Vector2d other) const @nogc nothrow pure @safe
    {
        return x * other.x + y * other.y;
    }

    double cross(Vector2d other) const @nogc nothrow pure @safe
    {
        return x * other.y - y * other.x;
    }

    Vector2d crossVecScalar(double s) const @nogc nothrow pure @safe
    {
        return Vector2d(s * y, -s * x);
    }

    Vector2d crossScalarVec(double s) const @nogc nothrow pure @safe
    {
        return Vector2d(-s * y, s * x);
    }

    double angleRad() const @nogc nothrow pure @safe
    {
        import math = deltotum.math;

        immutable angle = math.atan2(y, x);
        return angle;
    }

    double angleDeg() const @nogc nothrow pure @safe
    {
        import math = deltotum.math;

        immutable anleDeg = math.radToDeg(angleRad);
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

    static Vector2d fromPolarDeg(double angleDeg, double radius) @nogc nothrow pure @safe
    {
        import Math = deltotum.math;

        return fromPolarRad(Math.degToRad(angleDeg), radius);
    }

    static Vector2d fromPolarRad(double angleRad, double radius) @nogc nothrow pure @safe
    {
        import Math = deltotum.math;

        immutable pX = radius * Math.cos(angleRad);
        immutable pY = radius * Math.sin(angleRad);
        return Vector2d(pX, pY);
    }

    //TODO vector?
    static Vector2d toPolarRad(double x, double y) @nogc nothrow pure @safe
    {
        import Math = deltotum.math;

        const radius = Math.sqrt(x * x + y * y);
        const angleRad = Math.atan2(y, x);

        return Vector2d(radius, angleRad);
    }

    static Vector2d toPolarDeg(double x, double y) @nogc nothrow pure @safe
    {
        import Math = deltotum.math;

        const polarRad = toPolarRad(x, y);
        return Vector2d(polarRad.x, Math.radToDeg(polarRad.y));
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

    Vector2d reflectX() const @nogc nothrow pure @safe
    {
        return Vector2d(-x, y);
    }

    Vector2d reflectY() const @nogc nothrow pure @safe
    {
        return Vector2d(x, -y);
    }

    Vector2d reflect() const @nogc nothrow pure @safe
    {
        const newX = x == 0 ? 0 : -x;
        const newY = y == 0 ? 0 : -y;
        return Vector2d(newX, newY);
    }

    Vector2d min(Vector2d other) const @nogc nothrow pure @safe
    {
        import Math = deltotum.math;

        const newX = Math.min(x, other.x);
        const newY = Math.min(y, other.y);

        return Vector2d(newX, newY);
    }

    Vector2d max(Vector2d other) const @nogc nothrow pure @safe
    {
        import Math = deltotum.math;

        const newX = Math.max(x, other.x);
        const newY = Math.max(y, other.y);

        return Vector2d(newX, newY);
    }

    Vector2d truncate(double maxValue) const @nogc nothrow pure @safe
    {
        double scaleFactor = maxValue / this.magnitude;

        import std.math.operations : cmp;

        scaleFactor = cmp(scaleFactor, 1.0) < 0 ? scaleFactor : 1.0;
        Vector2d result = scale(scaleFactor);
        return result;
    }

    string toString() const
    {
        import std.format : format;

        return format("x:%.10f,y:%.10f", x, y);
    }

    void opOpAssign(string op)(Vector2d other)
    {
        const otherId = __traits(identifier, other);
        mixin("x" ~ op ~ "=" ~ otherId ~ ".x;");
        mixin("y" ~ op ~ "=" ~ otherId ~ ".y;");
    }

    Vector2d opBinary(string op)(Vector2d other) const @nogc nothrow pure @safe
    {
        static if (op == "+")
            return add(other);
        else static if (op == "-")
            return subtract(other);
        else
            static assert(0, "Operator " ~ op ~ " not implemented");
    }

    unittest
    {
        import std.math.operations : isClose;

        Vector2d v = Vector2d(5, 6);
        v += Vector2d(1, 1);
        assert(v.x == 6);
        assert(v.y == 7);

        v = Vector2d(3, 4);
        v -= Vector2d(1, 1);
        assert(v.x == 2);
        assert(v.y == 3);

        v = Vector2d(5, 6);
        auto addV = v + v;
        assert(addV.x == 10);
        assert(addV.y == 12);

        v = Vector2d(5, 6);
        auto subtractV = v - v;
        assert(subtractV.x == 0);
        assert(subtractV.y == 0);

        auto norm = Vector2d(5, 6).normalize;
        assert(isClose(norm.x, 0.640184, 1e-6));
        assert(isClose(norm.y, 0.768221, 1e-6));

        auto distance = Vector2d(5, 6).distanceTo(Vector2d(10, 12));
        assert(isClose(distance, 7.81025, 1e-6));

        Vector2d horizontalReflect = Vector2d(5, 6).linoperator(Matrix2x2([
                [-1, 0], [0, 1]
            ]));
        assert(horizontalReflect.x == -5);
        assert(horizontalReflect.y == 6);

        double dot = Vector2d(5, 6).dotProduct(Vector2d(2, 4));
        assert(dot == 34);
    }

}
