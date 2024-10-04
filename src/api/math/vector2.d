module api.math.vector2;

//TODO fast sqrt?
import std.math.algebraic : sqrt;
import std.math.operations : isClose;
import std.math.trigonometry : acos;
import std.math.constants : PI;
import api.math.matrices.matrix : Matrix2x2, Matrix2x1;

import Math = api.dm.math;

//TODO template with Vector2
struct Vector2i {
    int x;
    int y;
}

/**
 * Authors: initkfs
 */
//TODO template types, operator overloads
struct Vector2
{
    double x = 0;
    double y = 0;

    alias l1Norm = manhattan;
    alias l2norm = distanceTo;
    alias euclidean = distanceTo;
    alias length = magnitude;

    Vector2 add(Vector2 other) const @nogc nothrow pure @safe
    {
        return Vector2(x + other.x, y + other.y);
    }

    Vector2 subtract(Vector2 other) const @nogc nothrow pure @safe
    {
        return Vector2(x - other.x, y - other.y);
    }

    Vector2 subtractAbs(Vector2 other) const @nogc nothrow pure @safe
    {
        import Math = api.dm.math;

        return Vector2(Math.abs(x - other.x), Math.abs(y - other.y));
    }

    Vector2 normalize() const @nogc nothrow pure @safe
    {
        const double length = magnitude;
        double normX = 0;
        double normY = 0;
        if (length != 0)
        {
            normX = x / length;
            normY = y / length;
        }

        return Vector2(normX, normY);
    }

    Vector2 directionTo(Vector2 other) const @nogc nothrow pure @safe
    {
        return other.subtract(this).normalize;
    }

    Vector2 clone() const @nogc nothrow pure @safe
    {
        return Vector2(x, y);
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

    double distanceTo(Vector2 other) const @nogc nothrow pure @safe
    {
        const double powX = (other.x - x) ^^ 2;
        const double powY = (other.y - y) ^^ 2;
        return sqrt(powX + powY);
    }

    double manhattan(Vector2 other) const @nogc nothrow pure @safe
    {
        import Math = api.dm.math;

        return Math.abs(other.x - x) + Math.abs(other.y - y);
    }

    double cosineSimilarity(Vector2 other) const @nogc nothrow pure @safe
    {
        import Math = api.dm.math;

        return dotProduct(other) / (magnitude * other.magnitude);
    }

    Vector2 scale(double factor) const @nogc nothrow pure @safe
    {
        return Vector2(x * factor, y * factor);
    }

    Vector2 multiply(Vector2 other) const @nogc nothrow pure @safe
    {
        return Vector2(x * other.x, y * other.y);
    }

    Vector2 div(double factor) const @nogc nothrow pure @safe
    {
        assert(factor != 0);
        const newX = x / factor;
        const newY = y / factor;
        return Vector2(newX, newY);
    }

    Vector2 inc(double value) const @nogc nothrow pure @safe
    {
        return Vector2(x + value, y + value);
    }

    Vector2 incXY(double xValue, double yValud) const @nogc nothrow pure @safe
    {
        return Vector2(x + xValue, y + yValud);
    }

    Vector2 dec(double value) const @nogc nothrow pure @safe
    {
        return Vector2(x - value, y - value);
    }

    Vector2 perpendicular() const @nogc nothrow pure @safe
    {
        //or y, -x to left
        return Vector2(-y, x);
    }

    Vector2 translate(double tx, double ty) const @nogc nothrow pure @safe
    {
        return Vector2(x + tx, y + ty);
    }

    Vector2 rotate(double angleDeg) const @nogc nothrow pure @safe
    {
        immutable newX = x * Math.cosDeg(angleDeg) - y * Math.sinDeg(angleDeg);
        immutable newY = x * Math.sinDeg(angleDeg) + y * Math.cosDeg(angleDeg);
        return Vector2(newX, newY);
    }

    Vector2 shear(double sx, double sy) const @nogc nothrow pure @safe
    {
        immutable newX = x + sx * y;
        immutable newY = y + sy * x;
        return Vector2(newX, newY);
    }

    Vector2 project(double factor) const @nogc nothrow pure @safe
    in (factor != 0.0)
    {
        return Vector2(x / factor, y / factor);
    }

    double dotProduct(Vector2 other) const @nogc nothrow pure @safe
    {
        return x * other.x + y * other.y;
    }

    double cross(Vector2 other) const @nogc nothrow pure @safe
    {
        return x * other.y - y * other.x;
    }

    Vector2 crossVecScalar(double s) const @nogc nothrow pure @safe
    {
        return Vector2(s * y, -s * x);
    }

    Vector2 crossScalarVec(double s) const @nogc nothrow pure @safe
    {
        return Vector2(-s * y, s * x);
    }

    double angleRadTo(Vector2 other) const @nogc nothrow pure @safe
    {
        immutable direction = directionTo(other);
        immutable angle = angleRad(direction);
        return angle;
    }

    double angleDegTo(Vector2 other) const @nogc nothrow pure @safe
    {
        immutable angleRad = angleRadTo(other);
        immutable anleDeg = Math.radToDeg(angleRad);
        return anleDeg;
    }

    double angleDeg360To(Vector2 other) const @nogc nothrow pure @safe
    {
        auto anleDeg = angleDegTo(other);
        if (anleDeg < 0)
        {
            //TODO neg?
            anleDeg = (180 + (180 - Math.abs(anleDeg))) % 360;
        }
        return anleDeg;
    }

    double angleRad(Vector2 vec) const @nogc nothrow pure @safe
    {
        //clockwise 0..180, counter-clockwise 0..-180
        immutable angle = Math.atan2(vec.y, vec.x);
        return angle;
    }

    double angleDeg(Vector2 vec) const @nogc nothrow pure @safe
    {

        immutable anleDeg = Math.radToDeg(angleRad(vec));
        return anleDeg;
    }

    double angleRad() const @nogc nothrow pure @safe
    {
        return angleRad(this);
    }

    double angleDeg() const @nogc nothrow pure @safe
    {
        return angleDeg(this);
    }

    double angleDegBetween(Vector2 other) const @nogc nothrow pure @safe
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

    static Vector2 fromPolarDeg(double angleDeg, double radius) @nogc nothrow pure @safe
    {
        return fromPolarRad(Math.degToRad(angleDeg), radius);
    }

    static Vector2 fromPolarRad(double angleRad, double radius) @nogc nothrow pure @safe
    {
        immutable pX = radius * Math.cos(angleRad);
        immutable pY = radius * Math.sin(angleRad);
        return Vector2(pX, pY);
    }

    static Vector2 toPolarRad(Vector2 vec) @nogc nothrow pure @safe
    {
        return toPolarRad(vec.x, vec.y);
    }

    static Vector2 toPolarRad(double x, double y) @nogc nothrow pure @safe
    {
        const radius = Math.sqrt(x * x + y * y);
        const angleRad = Math.atan2(y, x);

        return Vector2(radius, angleRad);
    }

    static Vector2 toPolarDeg(Vector2 vec) @nogc nothrow pure @safe
    {
        return toPolarDeg(vec.x, vec.y);
    }

    static Vector2 toPolarDeg(double x, double y) @nogc nothrow pure @safe
    {
        const polarRad = toPolarRad(x, y);
        return Vector2(polarRad.x, Math.radToDeg(polarRad.y));
    }

    Matrix2x1 transpose() const pure @safe
    {
        return Matrix2x1([[x], [y]]);
    }

    Vector2 linoperator(Matrix2x2 linearOpMatrix) const pure @safe
    {
        Matrix2x1 result = linearOpMatrix.multiply(transpose);
        return Vector2(result.value(0, 0), result.value(1, 0));
    }

    Vector2 reflectX() const @nogc nothrow pure @safe
    {
        return Vector2(-x, y);
    }

    Vector2 reflectY() const @nogc nothrow pure @safe
    {
        return Vector2(x, -y);
    }

    Vector2 reflect() const @nogc nothrow pure @safe
    {
        const newX = x == 0 ? 0 : -x;
        const newY = y == 0 ? 0 : -y;
        return Vector2(newX, newY);
    }

    Vector2 min(Vector2 other) const @nogc nothrow pure @safe
    {
        const newX = Math.min(x, other.x);
        const newY = Math.min(y, other.y);

        return Vector2(newX, newY);
    }

    Vector2 max(Vector2 other) const @nogc nothrow pure @safe
    {
        const newX = Math.max(x, other.x);
        const newY = Math.max(y, other.y);

        return Vector2(newX, newY);
    }

    Vector2 truncate(double maxValue) const @nogc nothrow pure @safe
    {
        double scaleFactor = maxValue / this.magnitude;

        import std.math.operations : cmp;

        scaleFactor = cmp(scaleFactor, 1.0) < 0 ? scaleFactor : 1.0;
        Vector2 result = scale(scaleFactor);
        return result;
    }

    bool isZero() const @nogc pure @safe
    {
        return x == 0 && y == 0;
    }

    string toString() const
    {
        import std.format : format;

        return format("x:%.10f,y:%.10f", x, y);
    }

    void opIndexAssign(double value, size_t i) @safe
    {
        if (i == 0)
            x = value;
        else if (i == 1)
            y = value;
        else
        {
            import std.conv : text;

            throw new Exception(text("Invalid vector index: ", i));
        }
    }

    double opIndex(size_t i) const pure @safe
    {
        if (i == 0)
            return x;
        if (i == 1)
            return y;

        import std.conv : text;

        throw new Exception(text("Invalid vector index: ", i));
    }

    void opOpAssign(string op)(Vector2 other)
    {
        const otherId = __traits(identifier, other);
        mixin("x" ~ op ~ "=" ~ otherId ~ ".x;");
        mixin("y" ~ op ~ "=" ~ otherId ~ ".y;");
    }

    Vector2 opBinary(string op)(Vector2 other) const @nogc nothrow pure @safe
    {
        static if (op == "+")
            return add(other);
        else static if (op == "-")
            return subtract(other);
        else
            static assert(0, "Operator " ~ op ~ " not implemented");
    }

    Vector2i toInt(){
        return Vector2i(cast(int) x, cast(int) y);
    }

    unittest
    {
        import std.math.operations : isClose;

        Vector2 v = Vector2(5, 6);
        v += Vector2(1, 1);
        assert(v.x == 6);
        assert(v.y == 7);

        v = Vector2(3, 4);
        v -= Vector2(1, 1);
        assert(v.x == 2);
        assert(v.y == 3);

        v = Vector2(5, 6);
        auto addV = v + v;
        assert(addV.x == 10);
        assert(addV.y == 12);

        v = Vector2(5, 6);
        auto subtractV = v - v;
        assert(subtractV.x == 0);
        assert(subtractV.y == 0);

        auto norm = Vector2(5, 6).normalize;
        assert(isClose(norm.x, 0.640184, 1e-6));
        assert(isClose(norm.y, 0.768221, 1e-6));

        auto distance = Vector2(5, 6).distanceTo(Vector2(10, 12));
        assert(isClose(distance, 7.81025, 1e-6));

        Vector2 horizontalReflect = Vector2(5, 6).linoperator(Matrix2x2([
                [-1, 0], [0, 1]
            ]));
        assert(horizontalReflect.x == -5);
        assert(horizontalReflect.y == 6);

        double dot = Vector2(5, 6).dotProduct(Vector2(2, 4));
        assert(dot == 34);

        auto mVec1 = Vector2(23, 25);
        auto mVec2 = Vector2(11, 2);
        auto mres = mVec1.manhattan(mVec2);
        assert(isClose(mres, 35));

        auto cVec1 = Vector2(11, 12);
        auto cVec2 = Vector2(5, 6);
        auto cres = cVec1.cosineSimilarity(cVec2);
        assert(isClose(cres, 0.998886, 1e-6));
    }

}
