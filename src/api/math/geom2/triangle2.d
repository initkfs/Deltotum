module api.math.geom2.triangle2;

import api.math.geom2.vec2 : Vec2d;
import api.math.geom2.line2 : Line2d;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
struct Triangle2d
{
    Vec2d a;
    Vec2d b;
    Vec2d c;

    bool contains(Vec2d p) const @nogc pure @safe
    {
        immutable Vec2d barCoords = toBarycentric(p);
        bool isInside = (barCoords.x >= 0) && (barCoords.y >= 0) && ((barCoords.x + barCoords.y) <= 1);
        return isInside;
    }

    Vec2d toBarycentric(Vec2d p) const @nogc pure @safe
    {
        immutable Vec2d v0 = b - a;
        immutable Vec2d v1 = c - a;
        immutable Vec2d v2 = p - a;

        immutable double d00 = v0.dotProduct(v0);
        immutable double d01 = v0.dotProduct(v1);
        immutable double d11 = v1.dotProduct(v1);
        immutable double d20 = v2.dotProduct(v0);
        immutable double d21 = v2.dotProduct(v1);

        immutable double denom = d00 * d11 - d01 * d01;
        immutable x = (d11 * d20 - d01 * d21) / denom;
        immutable y = (d00 * d21 - d01 * d20) / denom;
        return Vec2d(x, y);
    }

    bool hasVertex(Vec2d vertex) const @nogc pure @safe
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
    auto trig1 = Triangle2d(Vec2d(10, 10), Vec2d(20, 10), Vec2d(15, 20));
    assert(trig1.contains(Vec2d(10, 10)));
    assert(trig1.contains(Vec2d(20, 10)));
    assert(trig1.contains(Vec2d(15, 20)));

    assert(!trig1.contains(Vec2d(9, 10)));
    assert(!trig1.contains(Vec2d(21, 10)));
    assert(!trig1.contains(Vec2d(16, 20)));

    assert(!trig1.contains(Vec2d(10, 9)));
    assert(!trig1.contains(Vec2d(20, 9)));
    assert(!trig1.contains(Vec2d(15, 21)));

}
