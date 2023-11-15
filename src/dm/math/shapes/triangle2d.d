module dm.math.shapes.triangle2d;

import dm.math.vector2 : Vector2;
import dm.math.line2d : Line2d;

import Math = dm.math;

/**
 * Authors: initkfs
 */
struct Triangle2d
{
    Vector2 a;
    Vector2 b;
    Vector2 c;

    bool contains(Vector2 p) const @nogc pure @safe
    {
        immutable Vector2 barCoords = toBarycentric(p);
        bool isInside = (barCoords.x >= 0) && (barCoords.y >= 0) && ((barCoords.x + barCoords.y) <= 1);
        return isInside;
    }

    Vector2 toBarycentric(Vector2 p) const @nogc pure @safe
    {
        immutable Vector2 v0 = b - a;
        immutable Vector2 v1 = c - a;
        immutable Vector2 v2 = p - a;

        immutable double d00 = v0.dotProduct(v0);
        immutable double d01 = v0.dotProduct(v1);
        immutable double d11 = v1.dotProduct(v1);
        immutable double d20 = v2.dotProduct(v0);
        immutable double d21 = v2.dotProduct(v1);

        immutable double denom = d00 * d11 - d01 * d01;
        immutable x = (d11 * d20 - d01 * d21) / denom;
        immutable y = (d00 * d21 - d01 * d20) / denom;
        return Vector2(x, y);
    }

    bool hasVertex(Vector2 vertex) const @nogc pure @safe
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
    auto trig1 = Triangle2d(Vector2(10, 10), Vector2(20, 10), Vector2(15, 20));
    assert(trig1.contains(Vector2(10, 10)));
    assert(trig1.contains(Vector2(20, 10)));
    assert(trig1.contains(Vector2(15, 20)));

    assert(!trig1.contains(Vector2(9, 10)));
    assert(!trig1.contains(Vector2(21, 10)));
    assert(!trig1.contains(Vector2(16, 20)));

    assert(!trig1.contains(Vector2(10, 9)));
    assert(!trig1.contains(Vector2(20, 9)));
    assert(!trig1.contains(Vector2(15, 21)));

}
