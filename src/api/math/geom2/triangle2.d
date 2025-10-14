module api.math.geom2.triangle2;

import api.math.geom2.vec2 : Vec2d;
import api.math.geom2.line2 : Line2d;
import api.math.geom2.circle2 : Circle2d;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
struct Triangle2d
{
    Vec2d a;
    Vec2d b;
    Vec2d c;

    bool contains(Vec2d p) const  pure @safe
    {
        immutable Vec2d barCoords = toBarycentric(p);
        bool isInside = (barCoords.x >= 0) && (barCoords.y >= 0) && ((barCoords.x + barCoords.y) <= 1);
        return isInside;
    }

    Vec2d toBarycentric(Vec2d p) const  pure @safe
    {
        immutable Vec2d v0 = b - a;
        immutable Vec2d v1 = c - a;
        immutable Vec2d v2 = p - a;

        immutable double d00 = v0.dot(v0);
        immutable double d01 = v0.dot(v1);
        immutable double d11 = v1.dot(v1);
        immutable double d20 = v2.dot(v0);
        immutable double d21 = v2.dot(v1);

        immutable double denom = d00 * d11 - d01 * d01;
        immutable x = (d11 * d20 - d01 * d21) / denom;
        immutable y = (d00 * d21 - d01 * d20) / denom;
        return Vec2d(x, y);
    }

    //https://totologic.blogspot.com/2014/01/accurate-point-in-triangle-test.html
    bool contains2(Vec2d p) const  pure @safe
    {
        float denom = ((b.y - c.y) * (a.x - c.x) + (c.x - b.x) * (a.y - c.y));

        float aa = ((b.y - c.y) * (p.x - c.x) + (c.x - b.x) * (p.y - c.y)) / denom;
        float bb = ((c.y - a.y) * (p.x - c.x) + (a.x - c.x) * (p.y - c.y)) / denom;
        float cc = 1 - aa - bb;

        if (aa > 0 && aa < 1 && bb > 0 && bb < 1 && cc > 0 && cc < 1)
        {
            return true;
        }

        return false;
    }

    bool hasVertex(Vec2d vertex) const  pure @safe
    {
        if (a == vertex || b == vertex || c == vertex)
        {
            return true;
        }

        return false;
    }

    size_t commonVertices(Triangle2d other)
    {
        const Vec2d[3] verts = [other.a, other.b, other.c];
        size_t commonVerts;
        foreach (otherV; verts)
        {
            if (a == otherV || b == otherV || c == otherV)
            {
                commonVerts++;
            }
        }
        return commonVerts;
    }

    bool isNeighbor(Triangle2d other) => commonVertices(other) == 2;
    bool isAdjacent(Triangle2d other) => commonVertices(other) != 0;
    

    Vec2d circumcircleCenter()
    {
        //https://en.wikipedia.org/wiki/Circumcircle#Circumcenter_coordinates
        const ax = a.x;
        const ay = a.y;
        const bx = b.x;
        const by = b.y;
        const cx = c.x;
        const cy = c.y;

        const d = 2 * (ax * (by - cy) + bx * (cy - ay) + cx * (ay - by));

        const centerX = 1 / d * ((ax * ax + ay * ay) * (by - cy) + (
                bx * bx + by * by) * (
                cy - ay) + (cx * cx + cy * cy) * (ay - by));

        const centerY = 1 / d * ((ax * ax + ay * ay) * (cx - bx) + (
                bx * bx + by * by) * (
                ax - cx) + (cx * cx + cy * cy) * (bx - ax));

        return Vec2d(centerX, centerY);
    }

    Circle2d circumcircle()
    {
        const center = circumcircleCenter;
        const radius = a.subtract(center).length;
        return Circle2d(center, radius);
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
