module api.math.geom2.triangle2;

import api.math.geom2.vec2 : Vec2f;
import api.math.geom2.line2 : Line2f;
import api.math.geom2.circle2 : Circle2f;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
struct Triangle2f
{
    Vec2f a;
    Vec2f b;
    Vec2f c;

    bool contains(Vec2f p) const pure @safe
    {
        immutable Vec2f barCoords = toBarycentric(p);
        bool isInside = (barCoords.x >= 0) && (barCoords.y >= 0) && ((barCoords.x + barCoords.y) <= 1);
        return isInside;
    }

    Vec2f toBarycentric(Vec2f p) const pure @safe
    {
        immutable Vec2f v0 = b - a;
        immutable Vec2f v1 = c - a;
        immutable Vec2f v2 = p - a;

        immutable float d00 = v0.dot(v0);
        immutable float d01 = v0.dot(v1);
        immutable float d11 = v1.dot(v1);
        immutable float d20 = v2.dot(v0);
        immutable float d21 = v2.dot(v1);

        immutable float denom = d00 * d11 - d01 * d01;
        immutable x = (d11 * d20 - d01 * d21) / denom;
        immutable y = (d00 * d21 - d01 * d20) / denom;
        return Vec2f(x, y);
    }

    //https://totologic.blogspot.com/2014/01/accurate-point-in-triangle-test.html
    bool contains2(Vec2f p) const pure @safe
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

    bool hasVertex(Vec2f vertex) const pure @safe
    {
        if (a == vertex || b == vertex || c == vertex)
        {
            return true;
        }

        return false;
    }

    size_t commonVertices(Triangle2f other)
    {
        const Vec2f[3] verts = [other.a, other.b, other.c];
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

    bool isNeighbor(Triangle2f other) => commonVertices(other) == 2;
    bool isAdjacent(Triangle2f other) => commonVertices(other) != 0;

    Vec2f circumcircleCenter()
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

        return Vec2f(centerX, centerY);
    }

    Circle2f circumcircle()
    {
        const center = circumcircleCenter;
        const radius = a.sub(center).length;
        return Circle2f(center, radius);
    }

    string toString() const
    {
        import std.conv : text;

        return text(typeof(this).stringof, " A(", a, "),B(", b, "),C(", c, ")");
    }
}

unittest
{
    auto trig1 = Triangle2f(Vec2f(10, 10), Vec2f(20, 10), Vec2f(15, 20));
    assert(trig1.contains(Vec2f(10, 10)));
    assert(trig1.contains(Vec2f(20, 10)));
    assert(trig1.contains(Vec2f(15, 20)));

    assert(!trig1.contains(Vec2f(9, 10)));
    assert(!trig1.contains(Vec2f(21, 10)));
    assert(!trig1.contains(Vec2f(16, 20)));

    assert(!trig1.contains(Vec2f(10, 9)));
    assert(!trig1.contains(Vec2f(20, 9)));
    assert(!trig1.contains(Vec2f(15, 21)));

}
