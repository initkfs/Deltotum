module api.dm.addon.math.geom2.convex_hull;

import api.math.geom2.polygon2 : Polygon2f;
import api.math.geom2.vec2 : Vec2f;
import Points = api.math.geom2.points2;
import Math = api.math;

/**
 * Authors: initkfs
 */

/** 
 * 
 * https://en.wikipedia.org/wiki/Graham_scan
 * Port from https://github.com/bkiers/GrahamScan
 * under MIT License https://github.com/bkiers/GrahamScan/blob/master/LICENSE.txt
 */
Vec2f[] graham(Vec2f[] points)
{
    Vec2f[] result;

    enum minPoints = 3;
    if (points.length < minPoints)
    {
        return result;
    }

    Vec2f[] hullPoints = points.dup;

    Vec2f lowest = hullPoints[0];
    foreach (ref p; hullPoints[1 .. $])
    {
        if (p.y < lowest.y || (p.y == lowest.y && p.x < lowest.x))
        {
            lowest = p;
        }
    }

    import std.algorithm.sorting : sort;

    hullPoints.sort!((Vec2f a, Vec2f b) {

        float thetaA = Math.atan2(a.y - lowest.y, a.x - lowest.x);
        float thetaB = Math.atan2(b.y - lowest.y, b.x - lowest.x);

        if (thetaA < thetaB)
        {
            return true;
        }

        if (thetaA > thetaB)
        {
            return false;
        }

        float distA = Math.sqrt(((lowest.x - a.x) * (lowest.x - a.x)) +
            (
            (lowest.y - a.y) * (lowest.y - a.y)));
        float distB = Math.sqrt(((lowest.x - b.x) * (lowest.x - b.x)) +
            (
            (lowest.y - b.y) * (lowest.y - b.y)));

        return distA < distB ? true : false;
    });

    if (Points.collinear(hullPoints))
    {
        return result;
    }

    import std.container.slist : SList;

    SList!Vec2f stack;
    stack.insert(hullPoints[0]);
    stack.insert(hullPoints[1]);

    for (int i = 2; i < hullPoints.length; i++)
    {
        Vec2f head = hullPoints[i];
        Vec2f middle = stack.front;
        stack.removeFront;
        Vec2f tail = stack.front;

        const orientation = Points.orientation(tail, middle, head);

        final switch (orientation) with (Points.PointsOrientation)
        {
            case counterClockwise:
                stack.insert(middle);
                stack.insert(head);
                break;
            case clockwise:
                i--;
                break;
            case collinear:
                stack.insert(head);
                break;

        }
    }

    stack.insert(hullPoints[0]);

    import std.range : walkLength;

    //TODO more optimal
    import std.array : array;

    result = stack.array;

    return result;
}

unittest
{
    import std.math.operations : isClose;

    Vec2f[] points = [
        Vec2f(1, 1), Vec2f(2, 2,), Vec2f(3, 2), Vec2f(3, 1), Vec2f(4, 3),
        Vec2f(1, 4), Vec2f(2, 3)
    ];
    Vec2f[] res1 = graham(points);
    Vec2f[] expected1 = [
        Vec2f(1, 1),
        Vec2f(1, 4),
        Vec2f(4, 3),
        Vec2f(3, 1),
        Vec2f(1, 1),
    ];
    assert(res1 == expected1);
}