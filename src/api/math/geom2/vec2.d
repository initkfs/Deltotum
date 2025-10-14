module api.math.geom2.vec2;

//TODO fast sqrt?
import std.math.algebraic : sqrt;
import std.math.operations : isClose;
import std.math.trigonometry : acos;
import std.math.constants : PI;
import api.math.matrices.matrix : Matrix2x2, Matrix2x1;

import Math = api.dm.math;

//TODO template with Vec2d
struct Vec2i
{
    int x;
    int y;
}

struct Vec2f
{
    float x;
    float y;
}

/**
 * Authors: initkfs
 */
//TODO template types, operator overloads
struct Vec2d
{
    double x = 0;
    double y = 0;

    alias l1Norm = manhattan;
    alias l2norm = distanceTo;
    alias euclidean = distanceTo;
    alias magnitude = length;

    static nothrow pure @safe Vec2d zero() => Vec2d();
    nothrow pure @safe bool isZero() const => (x == 0) && (y == 0);
    static nothrow pure @safe Vec2d infinity() => Vec2d(double.infinity, double.infinity);
    bool isInfinity() const => (x == double.infinity) || (y == double.infinity);

    static Vec2d fromPolarDeg(double angleDeg, double radius) nothrow pure @safe
    {
        return fromPolarRad(Math.degToRad(angleDeg), radius);
    }

    static Vec2d fromPolarRad(double angleRad, double radius) nothrow pure @safe
    {
        immutable pX = radius * Math.cos(angleRad);
        immutable pY = radius * Math.sin(angleRad);
        return Vec2d(pX, pY);
    }

    static Vec2d toPolarRad(Vec2d vec) nothrow pure @safe => toPolarRad(vec.x, vec.y);

    static Vec2d toPolarRad(double x, double y) nothrow pure @safe
    {
        const radius = Math.sqrt(x * x + y * y);
        const angleRad = Math.atan2(y, x);

        return Vec2d(radius, angleRad);
    }

    static Vec2d toPolarDeg(Vec2d vec) nothrow pure @safe => toPolarDeg(vec.x, vec.y);

    static Vec2d toPolarDeg(double x, double y) nothrow pure @safe
    {
        const polarRad = toPolarRad(x, y);
        return Vec2d(polarRad.x, Math.radToDeg(polarRad.y));
    }

    const nothrow pure @safe
    {
        Vec2d add(Vec2d other) => Vec2d(x + other.x, y + other.y);

        Vec2d sub(Vec2d other) => Vec2d(x - other.x, y - other.y);

        Vec2d subAbs(Vec2d other)
        {
            import Math = api.dm.math;

            return Vec2d(Math.abs(x - other.x), Math.abs(y - other.y));
        }

        Vec2d normalize()
        {
            const double len = length;
            double normX = 0;
            double normY = 0;
            if (len != 0)
            {
                normX = x / len;
                normY = y / len;
            }

            return Vec2d(normX, normY);
        }

        Vec2d directionTo(Vec2d other) => other.sub(this).normalize;

        Vec2d clone() => Vec2d(x, y);

        double length() => lengthXY(x, y);
        double lengthSquared() => lengthSquaredXY(x, y);
        double lengthSquaredXY(double x, double y) => x * x + y * y;
        double lengthXY(double x, double y) => sqrt(lengthSquaredXY(x, y));

        double distanceTo(Vec2d other)
        {
            const double powX = (other.x - x) ^^ 2;
            const double powY = (other.y - y) ^^ 2;
            return sqrt(powX + powY);
        }

        double manhattan(Vec2d other)
        {
            return Math.abs(other.x - x) + Math.abs(other.y - y);
        }

        double cosineSimilarity(Vec2d other)
        {
            return dot(other) / (length * other.length);
        }

        Vec2d scale(double factor) => Vec2d(x * factor, y * factor);

        Vec2d mul(Vec2d other)
        {
            return Vec2d(x * other.x, y * other.y);
        }

        Vec2d div(double factor)
        {
            assert(factor != 0);
            const newX = x / factor;
            const newY = y / factor;
            return Vec2d(newX, newY);
        }

        Vec2d inc(double value) => Vec2d(x + value, y + value);
        Vec2d incXY(double xValue, double yValue) => Vec2d(
            x + xValue, y + yValue);

        Vec2d decXY(double xValue, double yValue) => Vec2d(
            x - xValue, y - yValue);
        Vec2d dec(double value) => Vec2d(x - value, y - value);

        Vec2d perpendicular()
        {
            //(-y, x), rotate 90 deg ccw
            //(y, -x), rotate 90 cw
            return Vec2d(-y, x);
        }

        Vec2d translate(double tx, double ty) => Vec2d(x + tx, y + ty);

        Vec2d rotate(double angleDeg)
        {
            immutable newX = x * Math.cosDeg(angleDeg) - y * Math.sinDeg(angleDeg);
            immutable newY = x * Math.sinDeg(angleDeg) + y * Math.cosDeg(angleDeg);
            return Vec2d(newX, newY);
        }

        Vec2d shear(double sx, double sy)
        {
            immutable newX = x + sx * y;
            immutable newY = y + sy * x;
            return Vec2d(newX, newY);
        }

        Vec2d projectTo(Vec2d other)
        {
            const norm = normalize;
            const otherProject = norm.scale(norm.dot(other));
            return otherProject;
        }

        double project(Vec2d other)
        {
            const dop = dot(other);
            const otherLen = other.length;
            return dop / otherLen;
        }

        Vec2d project(double factor)
        in (factor != 0.0)
        {
            return Vec2d(x / factor, y / factor);
        }

        double dot(Vec2d other) => x * other.x + y * other.y;

        bool isCollinear(Vec2d other) => cross(other) == 0;

        double cross(Vec2d other) => x * other.y - y * other.x;

        static double cross(Vec2d p0, Vec2d p1, Vec2d p2) nothrow pure @safe
        {
            return (p1.x - p0.x) * (p2.y - p0.y) -
                (p2.x - p0.x) * (p1.y - p0.y);
        }

        Vec2d crossVecScalar(double s) => Vec2d(s * y, -s * x);
        Vec2d crossScalarVec(double s) => Vec2d(-s * y, s * x);

        double angleRadTo(Vec2d other)
        {
            immutable direction = directionTo(other);
            immutable angle = angleRad(direction);
            return angle;
        }

        double angleDegTo(Vec2d other)
        {
            immutable angleRad = angleRadTo(other);
            immutable anleDeg = Math.radToDeg(angleRad);
            return anleDeg;
        }

        double angleDeg360To(Vec2d other)
        {
            auto anleDeg = angleDegTo(other);
            if (anleDeg < 0)
            {
                //TODO neg?
                anleDeg = (180 + (180 - Math.abs(anleDeg))) % 360;
            }
            return anleDeg;
        }

        double angleRad(Vec2d vec)
        {
            //clockwise 0..180, counter-clockwise 0..-180
            immutable angle = Math.atan2(vec.y, vec.x);
            return angle;
        }

        double angleDeg(Vec2d vec)
        {
            immutable anleDeg = Math.radToDeg(angleRad(vec));
            return anleDeg;
        }

        double angleRad() => angleRad(this);
        double angleDeg() => angleDeg(this);

        double angleDegBetween(Vec2d other)
        {
            const double delta = (x * other.x + y * other.y) / sqrt(
                lengthSquaredXY(x, y) * lengthSquaredXY(other.x, other.y));

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

        Vec2d reflectX() => Vec2d(-x, y);
        Vec2d reflectY() => Vec2d(x, -y);

        Vec2d reflect()
        {
            const newX = x == 0 ? 0 : -x;
            const newY = y == 0 ? 0 : -y;
            return Vec2d(newX, newY);
        }

        Vec2d min(Vec2d other)
        {
            const newX = Math.min(x, other.x);
            const newY = Math.min(y, other.y);

            return Vec2d(newX, newY);
        }

        Vec2d max(Vec2d other)
        {
            const newX = Math.max(x, other.x);
            const newY = Math.max(y, other.y);

            return Vec2d(newX, newY);
        }

        Vec2d truncate(double maxValue)
        {
            double scaleFactor = maxValue / this.length;

            import std.math.operations : cmp;

            scaleFactor = cmp(scaleFactor, 1.0) < 0 ? scaleFactor : 1.0;
            Vec2d result = scale(scaleFactor);
            return result;
        }

        Vec2d clip(double minX, double minY, double maxX, double maxY)
        {
            auto x = Math.clamp(x, minX, maxX);
            auto y = Math.clamp(y, minY, maxY);
            return Vec2d(x, y);
        }

        Vec2i toInt() => Vec2i(cast(int) x, cast(int) y);

        Vec2d opBinary(string op)(Vec2d other)
        {
            static if (op == "+")
                return add(other);
            else static if (op == "-")
                return sub(other);
            else
                static assert(0, "Operator " ~ op ~ " not implemented");
        }
    }

    Matrix2x1 transpose() const pure @safe => Matrix2x1([[x], [y]]);

    Vec2d linoperator(Matrix2x2 linearOpMatrix) const pure @safe
    {
        Matrix2x1 result = linearOpMatrix.mul(transpose);
        return Vec2d(result.value(0, 0), result.value(1, 0));
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

    void opOpAssign(string op)(Vec2d other)
    {
        const otherId = __traits(identifier, other);
        mixin("x" ~ op ~ "=" ~ otherId ~ ".x;");
        mixin("y" ~ op ~ "=" ~ otherId ~ ".y;");
    }

    string toString() const
    {
        import std.format : format;

        return format("x:%.10f,y:%.10f", x, y);
    }
}

unittest
{
    import std.math.operations : isClose;

    Vec2d v = Vec2d(5, 6);
    v += Vec2d(1, 1);
    assert(v.x == 6);
    assert(v.y == 7);

    v = Vec2d(3, 4);
    v -= Vec2d(1, 1);
    assert(v.x == 2);
    assert(v.y == 3);

    v = Vec2d(5, 6);
    auto addV = v + v;
    assert(addV.x == 10);
    assert(addV.y == 12);

    v = Vec2d(5, 6);
    auto subtractV = v - v;
    assert(subtractV.x == 0);
    assert(subtractV.y == 0);

    auto norm = Vec2d(5, 6).normalize;
    assert(isClose(norm.x, 0.640184, 1e-6));
    assert(isClose(norm.y, 0.768221, 1e-6));

    auto distance = Vec2d(5, 6).distanceTo(Vec2d(10, 12));
    assert(isClose(distance, 7.81025, 1e-6));

    Vec2d horizontalReflect = Vec2d(5, 6).linoperator(Matrix2x2([
            [-1, 0], [0, 1]
    ]));
    assert(horizontalReflect.x == -5);
    assert(horizontalReflect.y == 6);

    double dot = Vec2d(5, 6).dot(Vec2d(2, 4));
    assert(dot == 34);

    auto mVec1 = Vec2d(23, 25);
    auto mVec2 = Vec2d(11, 2);
    auto mres = mVec1.manhattan(mVec2);
    assert(isClose(mres, 35));

    auto cVec1 = Vec2d(11, 12);
    auto cVec2 = Vec2d(5, 6);
    auto cres = cVec1.cosineSimilarity(cVec2);
    assert(isClose(cres, 0.998886, 1e-6));
}
