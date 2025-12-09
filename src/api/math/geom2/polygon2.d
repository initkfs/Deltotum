module api.math.geom2.polygon2;

import api.math.geom2.line2 : Line2f;
import api.math.geom2.vec2 : Vec2f;
import api.math.geom2.rect2: Rect2f;

import Math = api.math;

struct Quadrilateral2f
{
    Vec2f leftTop;
    Vec2f rightTop;
    Vec2f rightBottom;
    Vec2f leftBottom;

    this(float x, float y, float width, float height)
    {
        leftTop = Vec2f(x, y);
        rightTop = Vec2f(leftTop.x + width, leftTop.y);
        rightBottom = Vec2f(rightTop.x, rightTop.y + height);
        leftBottom = Vec2f(leftTop.x, rightBottom.y);
    }

    Vec2f middleLeft() const  nothrow pure @safe => leftBottom.add(leftTop).div(2.0);
    Vec2f middleRight() const  nothrow pure @safe => rightBottom.add(rightTop).div(2.0);
    Vec2f middleTop() const  nothrow pure @safe => rightTop.add(leftTop).div(2.0);
    Vec2f middleBottom() const  nothrow pure @safe => rightBottom.add(
        leftBottom).div(2.0);

    Vec2f center() const nothrow pure @safe
    {
        import api.math.geom2.polygon2 : Polygon2f;

        Vec2f[4] vertx = [leftTop, rightTop, rightBottom, leftBottom];
        const poly = Polygon2f(vertx[]);
        return poly.midpoint;
    }
}

/**
 * Authors: initkfs
 */
struct Polygon2f
{
    Vec2f[] vertices;

    bool contains(Vec2f point) => containsRayCast(point);

    bool containsRayCast(Vec2f point)
    {
        if (vertices.length == 0)
        {
            return false;
        }

        immutable vertLength = vertices.length;
        size_t crossCount;

        foreach (i, const ref Vec2f p1; vertices)
        {
            if (p1 == point)
            {
                return true;
            }

            Vec2f p2 = vertices[(i + 1) % vertLength];

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

    bool containsRayCross(Vec2f point)
    {
        size_t vertLength = vertices.length;

        bool isIntersect;

        foreach (i, const ref Vec2f p1; vertices)
        {
            if (point == p1)
            {
                return true;
            }

            Vec2f p2 = vertices[(i + 1) % vertLength];

            immutable bool yCross = (p1.y > point.y) != (p2.y > point.y);
            immutable xCross = (p2.x - p1.x) * (point.y - p1.y) / (p2.y - p1.y) + p1.x;
            if (yCross && point.x < xCross)
            {
                isIntersect = !isIntersect;
            }
        }

        return isIntersect;
    }

    bool containsWinding(Vec2f point)
    {
        float cross3p(Vec2f p1, Vec2f p2, Vec2f p3) => (p2.x - p1.x) * (
            p3.y - p1.y)
            - (p2.y - p1.y) * (p3.x - p1.x);

        bool isOnSegment(Vec2f p, Vec2f p1, Vec2f p2) =>
            cross3p(p1, p2, p) == 0
            && p.x >= Math.min(p1.x, p2.x)
            && p.x <= Math.max(p1.x, p2.x)
            && p.y >= Math.min(p1.y, p2.y)
            && p.y <= Math.max(p1.y, p2.y);

        size_t vertLength = vertices.length;
        int crossCount = 0;

        foreach (i, const ref Vec2f p1; vertices)
        {
            Vec2f p2 = vertices[(i + 1) % vertLength];

            //TODO float check
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

        float vertSum = 0;

        //(x2 - x1) * (y2 + y1)
        foreach (i, const ref current; vertices)
        {
            if (i == 0)
            {
                continue;
            }

            const Vec2f* prev = &vertices[i - 1];
            const dx = current.x - prev.x;
            const dy = current.y + prev.y;

            vertSum += dx * dy;
        }

        return vertSum > 0;
    }

    Vec2f midpoint() scope const nothrow pure @safe
    {
        float xSum = 0;
        float ySum = 0;
        foreach (ref p; vertices)
        {
            xSum += p.x;
            ySum += p.y;
        }

        return Vec2f(xSum / vertices.length, ySum / vertices.length);
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
            const float pm1 = (Math.radToDeg(Math.atan2(p1.x - mid.x, p1.y - mid.y)) + 360) % 360;
            const float pm2 = (Math.radToDeg(Math.atan2(p2.x - mid.x, p2.y - mid.y)) + 360) % 360;
            const int dm = isClockwise ? cast(int)(pm1 - pm2) : cast(int)(pm2 - pm1);
            return dm < 0;
        });
    }

    float closedArea()
    {
        float result = 0;

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

    void onLineMidpoint(scope bool delegate(Vec2f) onMidIsContinue, bool isLastLineNeed = true)
    {
        onLine((line) { return onMidIsContinue(line.midpoint); }, isLastLineNeed);
    }

    void onLine(scope bool delegate(Line2f) onLineIsContinue, bool isLastLineNeed = true)
    {

        if (vertices.length < 3)
        {
            return;
        }

        foreach (i, ref Vec2f vert; vertices)
        {
            if (i == 0)
            {
                continue;
            }
            if (!onLineIsContinue(Line2f(vertices[i - 1], vert)))
            {
                return;
            }
        }

        if (isLastLineNeed)
        {
            onLineIsContinue(Line2f(vertices[$ - 1], vertices[0]));
        }
    }

    bool isConvex()
    {
        float prevCross = 0;
        float currCross = 0;
        foreach (i, ref point; vertices)
        {
            auto next1 = vertices[(i + 1) % vertices.length];
            auto next2 = vertices[(i + 2) % vertices.length];

            currCross = Vec2f.cross(point, next1, next2);
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
        Vec2f[] points = [{0, 0}, {0, 5}, {5, 5}, {5, 0}];
        assert((Polygon2f(points)).isConvex);

        Vec2f[] points2 = [{0, 0}, {0, 5}, {0, 0}, {5, 5}, {5, 0}];
        assert(!(Polygon2f(points2)).isConvex);

    }

    /** 
     * https://en.wikipedia.org/wiki/Sutherland-Hodgman_algorithm
     * https://www.geeksforgeeks.org/polygon-clipping-sutherland-hodgman-algorithm/
     */
    static Vec2f[] clipSutherlandHodgman(Vec2f[] points, Vec2f x1y1, Vec2f x2y2)
    {
        if (points.length == 0)
        {
            return [];
        }

        Vec2f[] newPoints;

        float x1 = x1y1.x;
        float y1 = x1y1.y;
        float x2 = x2y2.x;
        float y2 = x2y2.y;

        foreach (i; 0 .. points.length)
        {
            size_t k = (i + 1) % points.length;

            const ix = (points[i]).x, iy = (points[i]).y;
            const kx = (points[k]).x, ky = (points[k]).y;

            const ipos = (x2 - x1) * (iy - y1) - (y2 - y1) * (ix - x1);
            const kpos = (x2 - x1) * (ky - y1) - (y2 - y1) * (kx - x1);

            Line2f l1 = Line2f(x1, y1, x2, y2);
            Line2f l2 = Line2f(ix, iy, kx, ky);

            // points inside
            if (ipos < 0 && kpos < 0)
            {
                newPoints ~= Vec2f(kx, ky);
            }
            // first point outside
            else if (ipos >= 0 && kpos < 0)
            {
                const intersectPoint = l1.intersectWith(l2);
                newPoints ~= Vec2f(
                    intersectPoint.x,
                    intersectPoint.y);
                newPoints ~= Vec2f(kx, ky);
            }
            // second point outside
            else if (ipos < 0 && kpos >= 0)
            {
                const intersectPoint = l1.intersectWith(l2);
                //Only point of intersection with edge is added
                newPoints ~= Vec2f(
                    intersectPoint.x,
                    intersectPoint.y
                );
            }
        }

        return newPoints;
    }

    static Vec2f[] clipSutHodg(Vec2f[] points, Vec2f[] clipperPoints)
    {
        Vec2f[] clipPoints = points.dup;
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

        float eps = 0.00001;

        Vec2f[] points = [
            Vec2f(100.0, 150), Vec2f(200.0, 250), Vec2f(300.0, 200)
        ];
        Vec2f[] clipPoints = [
            Vec2f(150.0, 150), Vec2f(150.0, 200), Vec2f(200.0, 200),
            Vec2f(200.0, 150)
        ];

        Vec2f[] result = clipSutHodg(points, clipPoints);

        float[][] expected = [
            [150, 162.5], [150.0, 200], [200.0, 200], [200.0, 175]
        ];

        assert(result.length == expected.length);
        foreach (i, Vec2f poly; result)
        {
            auto expectPoint = expected[i];
            assert(isClose(poly.x, expectPoint[0], eps));
            assert(isClose(poly.y, expectPoint[1], eps));
        }
    }

    Rect2f bounds() const
    {
        float minX = 0;
        float maxX = 0;
        float minY = 0;
        float maxY = 0;
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

        return Rect2f(minX, minY, maxX - minX, maxY - minY);
    }

}

//TODO add mixin test
unittest
{
    Polygon2f poly1 = {[
        {10, 10}, {20, 10}, {20, 20}, {10, 20}
    ]};

    assert(!poly1.containsRayCast(Vec2f(9, 9)));
    assert(!poly1.containsRayCast(Vec2f(21, 10)));
    assert(!poly1.containsRayCast(Vec2f(20, 21)));
    assert(!poly1.containsRayCast(Vec2f(10, 21)));

    assert(poly1.containsRayCast(Vec2f(10, 10)));
    assert(poly1.containsRayCast(Vec2f(20, 10)));

    assert(poly1.containsRayCast(Vec2f(15, 15)));
    assert(poly1.containsRayCast(Vec2f(17, 11)));

}

unittest
{
    Polygon2f poly1 = {[
        {10, 10}, {20, 10}, {20, 20}, {10, 20}
    ]};

    assert(!poly1.containsRayCross(Vec2f(9, 9)));
    assert(!poly1.containsRayCross(Vec2f(21, 10)));
    assert(!poly1.containsRayCross(Vec2f(20, 21)));
    assert(!poly1.containsRayCross(Vec2f(10, 21)));

    assert(poly1.containsRayCross(Vec2f(10, 10)));
    assert(poly1.containsRayCross(Vec2f(20, 10)));

    assert(poly1.containsRayCross(Vec2f(15, 15)));
    assert(poly1.containsRayCross(Vec2f(17, 11)));

}

unittest
{
    Polygon2f poly1 = {[
        {10, 10}, {20, 10}, {20, 20}, {10, 20}
    ]};

    assert(!poly1.containsWinding(Vec2f(9, 9)));
    assert(!poly1.containsWinding(Vec2f(21, 10)));
    assert(!poly1.containsWinding(Vec2f(20, 21)));
    assert(!poly1.containsWinding(Vec2f(10, 21)));

    assert(poly1.containsWinding(Vec2f(10, 10)));
    assert(poly1.containsWinding(Vec2f(15, 10)));
    assert(poly1.containsWinding(Vec2f(20, 10)));

    assert(poly1.containsWinding(Vec2f(15, 15)));
    assert(poly1.containsWinding(Vec2f(17, 11)));

}
