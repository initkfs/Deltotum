module deltotum.math.vector3d;

//TODO fast sqrt?
import std.math.algebraic : sqrt;
import std.math.operations : isClose;
import std.math.trigonometry : acos;

/**
 * Authors: initkfs
 */
//TODO template types, operator overloads
struct Vector3D
{
    double x = 0;
    double y = 0;
    double z = 0;

    Vector3D add(Vector3D other) const @nogc nothrow @safe
    {
        return Vector3D(x + other.x, y + other.y, z + other.z);
    }

    Vector3D subtract(Vector3D other) const @nogc nothrow @safe
    {
        return Vector3D(x - other.x, y - other.y, z - other.z);
    }

    Vector3D normalize() const @nogc nothrow @safe
    {
        const double length = magnitude;
        double normX = 0;
        double normY = 0;
        double normZ = 0;
        if (!isClose(length, 0.0))
        {
            normX /= length;
            normY /= length;
            normZ /= normZ;
        }

        return Vector3D(normX, normY, normZ);
    }

    Vector3D clone() const @nogc nothrow @safe
    {
        return Vector3D(x, y, z);
    }

    double magnitude() const @nogc nothrow @safe
    {
        return magnitudeXYZ(x, y, z);
    }

    double magnitudeSquared() const @nogc nothrow @safe
    {
        return magnitudeSquaredXYZ(x, y, z);
    }

    double magnitudeSquaredXYZ(double x, double y, double z) const @nogc nothrow @safe
    {
        return x * x + y * y + z * z;
    }

    double magnitudeXYZ(double x, double y, double z) const @nogc nothrow @safe
    {
        return sqrt(magnitudeSquaredXYZ(x, y, z));
    }

    double distanceTo(Vector3D other) const @nogc nothrow @safe
    {
        const double deltaX = other.x - x;
        const double deltaY = other.y - y;
        const double deltaZ = other.z - z;
        return magnitudeXYZ(deltaX, deltaY, deltaZ);
    }

    Vector3D scale(double factor) const @nogc nothrow @safe
    {
        assert(!isClose(factor, 0.0));
        return Vector3D(x * factor, y * factor, z * factor);
    }

    Vector3D project(double factor) const @nogc nothrow @safe
    {
        assert(!isClose(factor, 0.0));
        return Vector3D(x / factor, y / factor, z / factor);
    }

    double dotProduct(Vector3D other) const @nogc nothrow @safe
    {
        return x * other.x + y * other.y + z * other.z;
    }

    Vector3D crossProduct(Vector3D other) const @nogc nothrow @safe
    {
        return Vector3D(y * other.z - z * other.y, z * other.x - x * other.z, x * other.y - y * other
                .x);
    }

    double angleBetween(Vector3D other) const @nogc nothrow @safe
    {
        const currentLength = magnitude;
        const otherLength = other.magnitude;
        double dot = dotProduct(other);
        if (!isClose(currentLength, 0.0))
        {
            dot /= currentLength;
        }

        if (!isClose(otherLength, 0.0))
        {
            dot /= otherLength;
        }

        return acos(dot);
    }

    string toString() immutable
    {
        import std.format : format;

        return format("x:%s,y:%s", x, y);
    }

}
