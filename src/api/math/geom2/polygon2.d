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

        foreach (i, const ref Vec2d p1; vertices)
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

    bool isClockwise()
    {
        if (vertices.length == 0)
        {
            return false;
        }

        double vertSum = 0;

        //(x2 - x1) * (y2 + y1)
        foreach (i, const ref current; vertices)
        {
            if (i == 0)
            {
                continue;
            }

            const Vec2d* prev = &vertices[i - 1];
            const dx = current.x - prev.x;
            const dy = current.y + prev.y;

            vertSum += dx * dy;
        }

        return vertSum > 0;
    }

    Vec2d midpoint()
    {
        double xSum = 0;
        double ySum = 0;
        foreach (ref p; vertices)
        {
            xSum += p.x;
            ySum += p.y;
        }

        return Vec2d(xSum / vertices.length, ySum / vertices.length);
    }

    //TODO https://math.stackexchange.com/questions/978642/how-to-sort-vertices-of-a-polygon-in-counter-clockwise-order
    void changeDirection(bool isClockwise = false)
    {
        //Point center = findCentroid(points);
        const mid = midpoint;

        import std.algorithm.sorting : sort;
        import Math = api.math;

        vertices.sort!((p1, p2) {
            //TODO check if xy correct for atan2(y, x) 
            const double pm1 = (Math.radToDeg(Math.atan2(p1.x - mid.x, p1.y - mid.y)) + 360) % 360;
            const double pm2 = (Math.radToDeg(Math.atan2(p2.x - mid.x, p2.y - mid.y)) + 360) % 360;
            const int dm = isClockwise ? cast(int)(pm1 - pm2) : cast(int)(pm2 - pm1);
            return dm < 0;
        });
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
