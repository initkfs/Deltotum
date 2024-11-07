module api.math.geom2.polygon2;

import api.math.geom2.line2 : Line2d;
import api.math.geom2.vec2 : Vec2d;
import api.math.geom2.rect2: Rect2d;

import Math = api.math;

/**
 * Authors: initkfs
 */
struct Polygon2d
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

    double closedArea()
    {
        double result = 0;

        if (vertices.length < 3)
        {
            return 0;
        }

        for (size_t i = vertices.length - 1, j; j < vertices.length; i = j++)
        {
            result += (vertices[i].x * vertices[j].y - vertices[j].x * vertices[i].y);
        }

        return result / 2;
    }

    void onLineMidpoint(scope bool delegate(Vec2d) onMidIsContinue, bool isLastLineNeed = true)
    {
        onLine((line) { return onMidIsContinue(line.midpoint); }, isLastLineNeed);
    }

    void onLine(scope bool delegate(Line2d) onLineIsContinue, bool isLastLineNeed = true)
    {

        if (vertices.length < 3)
        {
            return;
        }

        foreach (i, ref Vec2d vert; vertices)
        {
            if (i == 0)
            {
                continue;
            }
            if (!onLineIsContinue(Line2d(vertices[i - 1], vert)))
            {
                return;
            }
        }

        if (isLastLineNeed)
        {
            onLineIsContinue(Line2d(vertices[$ - 1], vertices[0]));
        }
    }

    bool isConvex()
    {
        double prevCross = 0;
        double currCross = 0;
        foreach (i, ref point; vertices)
        {
            auto next1 = vertices[(i + 1) % vertices.length];
            auto next2 = vertices[(i + 2) % vertices.length];

            currCross = Vec2d.cross(point, next1, next2);
            if (currCross != 0)
            {
                if (currCross * prevCross < 0)
                {
                    return false;
                }

                prevCross = currCross;
            }
        }
        return true;
    }

    unittest
    {
        Vec2d[] points = [{0, 0}, {0, 5}, {5, 5}, {5, 0}];
        assert((Polygon2d(points)).isConvex);

        Vec2d[] points2 = [{0, 0}, {0, 5}, {0, 0}, {5, 5}, {5, 0}];
        assert(!(Polygon2d(points2)).isConvex);

    }

    /** 
     * https://en.wikipedia.org/wiki/Sutherland-Hodgman_algorithm
     * https://www.geeksforgeeks.org/polygon-clipping-sutherland-hodgman-algorithm/
     */
    static Vec2d[] clipSutherlandHodgman(Vec2d[] points, Vec2d x1y1, Vec2d x2y2)
    {
        if (points.length == 0)
        {
            return [];
        }

        Vec2d[] newPoints;

        double x1 = x1y1.x;
        double y1 = x1y1.y;
        double x2 = x2y2.x;
        double y2 = x2y2.y;

        foreach (i; 0 .. points.length)
        {
            size_t k = (i + 1) % points.length;

            const ix = (points[i]).x, iy = (points[i]).y;
            const kx = (points[k]).x, ky = (points[k]).y;

            const ipos = (x2 - x1) * (iy - y1) - (y2 - y1) * (ix - x1);
            const kpos = (x2 - x1) * (ky - y1) - (y2 - y1) * (kx - x1);

            Line2d l1 = Line2d(x1, y1, x2, y2);
            Line2d l2 = Line2d(ix, iy, kx, ky);

            // points inside
            if (ipos < 0 && kpos < 0)
            {
                newPoints ~= Vec2d(kx, ky);
            }
            // first point outside
            else if (ipos >= 0 && kpos < 0)
            {
                const intersectPoint = l1.intersectWith(l2);
                newPoints ~= Vec2d(
                    intersectPoint.x,
                    intersectPoint.y);
                newPoints ~= Vec2d(kx, ky);
            }
            // second point outside
            else if (ipos < 0 && kpos >= 0)
            {
                const intersectPoint = l1.intersectWith(l2);
                //Only point of intersection with edge is added
                newPoints ~= Vec2d(
                    intersectPoint.x,
                    intersectPoint.y
                );
            }
        }

        return newPoints;
    }

    static Vec2d[] clipSutHodg(Vec2d[] points, Vec2d[] clipperPoints)
    {
        Vec2d[] clipPoints = points.dup;
        foreach (i; 0 .. clipperPoints.length)
        {
            size_t k = (i + 1) % clipperPoints.length;
            clipPoints = clipSutherlandHodgman(clipPoints, clipperPoints[i], clipperPoints[k]);
        }
        return clipPoints;
    }

    unittest
    {
        import std.math.operations : isClose;

        double eps = 0.00001;

        Vec2d[] points = [
            Vec2d(100.0, 150), Vec2d(200.0, 250), Vec2d(300.0, 200)
        ];
        Vec2d[] clipPoints = [
            Vec2d(150.0, 150), Vec2d(150.0, 200), Vec2d(200.0, 200),
            Vec2d(200.0, 150)
        ];

        Vec2d[] result = clipSutHodg(points, clipPoints);

        double[][] expected = [
            [150, 162.5], [150.0, 200], [200.0, 200], [200.0, 175]
        ];

        assert(result.length == expected.length);
        foreach (i, Vec2d poly; result)
        {
            auto expectPoint = expected[i];
            assert(isClose(poly.x, expectPoint[0], eps));
            assert(isClose(poly.y, expectPoint[1], eps));
        }
    }

    Rect2d bounds() const
    {
        double minX = 0;
        double maxX = 0;
        double minY = 0;
        double maxY = 0;
        foreach (ref p; vertices)
        {
            if (p.x < minX)
            {
                minX = p.x;
            }

            if (p.x > maxX)
            {
                maxX = p.x;
            }

            if (p.y < minY)
            {
                minY = p.y;
            }

            if (p.y > maxY)
            {
                maxY = p.y;
            }
        }

        return Rect2d(minX, minY, maxX - minX, maxY - minY);
    }

}

//TODO add mixin test
unittest
{
    Polygon2d poly1 = {[
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
    Polygon2d poly1 = {[
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
    Polygon2d poly1 = {[
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
