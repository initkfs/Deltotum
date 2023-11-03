module deltotum.math.shapes.triangle2d;

import deltotum.math.vector2d : Vector2d;
import deltotum.math.line2d : Line2d;

import Math = deltotum.math;

/**
 * Authors: initkfs
 */
struct Triangle2d
{
    Vector2d a;
    Vector2d b;
    Vector2d c;

    bool contains(Vector2d p) const @nogc pure @safe
    {
        immutable Vector2d barCoords = toBarycentric(p);
        bool isInside = (barCoords.x >= 0) && (barCoords.y >= 0) && ((barCoords.x + barCoords.y) <= 1);
        return isInside;
    }

    Vector2d toBarycentric(Vector2d p) const @nogc pure @safe
    {
        immutable Vector2d v0 = b - a;
        immutable Vector2d v1 = c - a;
        immutable Vector2d v2 = p - a;

        immutable double d00 = v0.dotProduct(v0);
        immutable double d01 = v0.dotProduct(v1);
        immutable double d11 = v1.dotProduct(v1);
        immutable double d20 = v2.dotProduct(v0);
        immutable double d21 = v2.dotProduct(v1);

        immutable double denom = d00 * d11 - d01 * d01;
        immutable x = (d11 * d20 - d01 * d21) / denom;
        immutable y = (d00 * d21 - d01 * d20) / denom;
        return Vector2d(x, y);
    }

    bool hasVertex(Vector2d vertex) const @nogc pure @safe
    {
        if (a == vertex || b == vertex || c == vertex)
        {
            return true;
        }

        return false;
    }

    string toString() const
    {
        import std.conv : text;

        return text(typeof(this).stringof, " A(", a, "),B(", b, "),C(", c, ")");
    }
}

unittest
{
    auto trig1 = Triangle2d(Vector2d(10, 10), Vector2d(20, 10), Vector2d(15, 20));
    assert(trig1.contains(Vector2d(10, 10)));
    assert(trig1.contains(Vector2d(20, 10)));
    assert(trig1.contains(Vector2d(15, 20)));

    assert(!trig1.contains(Vector2d(9, 10)));
    assert(!trig1.contains(Vector2d(21, 10)));
    assert(!trig1.contains(Vector2d(16, 20)));

    assert(!trig1.contains(Vector2d(10, 9)));
    assert(!trig1.contains(Vector2d(20, 9)));
    assert(!trig1.contains(Vector2d(15, 21)));

}
