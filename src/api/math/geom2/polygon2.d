module api.math.geom2.polygon2;

import api.math.geom2.line2 : Line2d;
import api.math.geom2.vec2 : Vec2d;

import Math = api.math;

/**
 * Authors: initkfs
 */
struct Polygon2
{
    Vec2d[] vertices;

    bool contains(Vec2d point) => containsRayCast(point);

    bool containsRayCast(Vec2d point)
    {
        if (vertices.length == 0)
        {
            return false;
        }

        immutable vertLength = vertices.length;
        size_t crossCount;

        foreach (i, const ref Vec2d p1; vertices)
        {
            if (p1 == point)
            {
                return true;
            }

            Vec2d p2 = vertices[(i + 1) % vertLength];

            if (
                (point.y > Math.min(p1.y, p2.y)) &&
                (point.y <= Math.max(p1.y, p2.y))
                && (point.x <= Math.max(p1.x, p2.x)))
            {
                immutable xCross = (point.y - p1.y) * (p2.x - p1.x) / (p2.y - p1.y) + p1.x;
                if (p1.x == p2.x || point.x <= xCross)
                {
                    crossCount++;
                }
            }
        }

        return crossCount % 2 == 1;
    }

    bool containsRayCross(Vec2d point)
    {
        size_t vertLength = vertices.length;

        bool isIntersect;

        foreach (i, const ref Vec2d p1; vertices)
        {
            if (point == p1)
            {
                return true;
            }

            Vec2d p2 = vertices[(i + 1) % vertLength];

            immutable bool yCross = (p1.y > point.y) != (p2.y > point.y);
            immutable xCross = (p2.x - p1.x) * (point.y - p1.y) / (p2.y - p1.y) + p1.x;
            if (yCross && point.x < xCross)
            {
                isIntersect = !isIntersect;
            }
        }

        return isIntersect;
    }

    bool containsWinding(Vec2d point)
    {
        double cross3p(Vec2d p1, Vec2d p2, Vec2d p3) => (p2.x - p1.x) * (
            p3.y - p1.y)
            - (p2.y - p1.y) * (p3.x - p1.x);

        bool isOnSegment(Vec2d p, Vec2d p1, Vec2d p2) =>
            cross3p(p1, p2, p) == 0
            && p.x >= Math.min(p1.x, p2.x)
            && p.x <= Math.max(p1.x, p2.x)
            && p.y >= Math.min(p1.y, p2.y)
            && p.y <= Math.max(p1.y, p2.y);

        size_t vertLength = vertices.length;
        int crossCount = 0;

        foreach(i, const ref Vec2d p1; vertices)
        {
            Vec2d p2 = vertices[(i + 1) % vertLength];

            //TODO double check
            if (p1 == point || p2 == point || isOnSegment(point, p1, p2))
            {
                return true;
            }

            //Check directions
            if (p1.y <= point.y)
            {
                if (p2.y > point.y && cross3p(p1, p2, point) > 0)
                {
                    crossCount++;
                }
            }
            else
            {
                if (p2.y <= point.y && cross3p(p1, p2, point) < 0)
                {
                    crossCount--;
                }
            }
        }
        return crossCount != 0;
    }
}

//TODO add mixin test
unittest
{
    Polygon2 poly1 = {[
        {10, 10}, {20, 10}, {20, 20}, {10, 20}
    ]};

    assert(!poly1.containsRayCast(Vec2d(9, 9)));
    assert(!poly1.containsRayCast(Vec2d(21, 10)));
    assert(!poly1.containsRayCast(Vec2d(20, 21)));
    assert(!poly1.containsRayCast(Vec2d(10, 21)));

    assert(poly1.containsRayCast(Vec2d(10, 10)));
    assert(poly1.containsRayCast(Vec2d(20, 10)));

    assert(poly1.containsRayCast(Vec2d(15, 15)));
    assert(poly1.containsRayCast(Vec2d(17, 11)));

}

unittest
{
    Polygon2 poly1 = {[
        {10, 10}, {20, 10}, {20, 20}, {10, 20}
    ]};

    assert(!poly1.containsRayCross(Vec2d(9, 9)));
    assert(!poly1.containsRayCross(Vec2d(21, 10)));
    assert(!poly1.containsRayCross(Vec2d(20, 21)));
    assert(!poly1.containsRayCross(Vec2d(10, 21)));

    assert(poly1.containsRayCross(Vec2d(10, 10)));
    assert(poly1.containsRayCross(Vec2d(20, 10)));

    assert(poly1.containsRayCross(Vec2d(15, 15)));
    assert(poly1.containsRayCross(Vec2d(17, 11)));

}

unittest
{
    Polygon2 poly1 = {[
        {10, 10}, {20, 10}, {20, 20}, {10, 20}
    ]};

    assert(!poly1.containsWinding(Vec2d(9, 9)));
    assert(!poly1.containsWinding(Vec2d(21, 10)));
    assert(!poly1.containsWinding(Vec2d(20, 21)));
    assert(!poly1.containsWinding(Vec2d(10, 21)));

    assert(poly1.containsWinding(Vec2d(10, 10)));
    assert(poly1.containsWinding(Vec2d(15, 10)));
    assert(poly1.containsWinding(Vec2d(20, 10)));

    assert(poly1.containsWinding(Vec2d(15, 15)));
    assert(poly1.containsWinding(Vec2d(17, 11)));

}
