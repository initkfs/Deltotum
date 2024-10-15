module api.math.geom2.convex_hull;

import api.math.geom2.polygon2 : Polygon2;
import api.math.geom2.vec2 : Vec2d;
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
Vec2d[] grahamScan(Vec2d[] points)
{
    Vec2d[] result;

    enum minPoints = 3;
    if (points.length < 3)
    {
        return result;
    }

    Vec2d[] hullPoints = points.dup;

    Vec2d lowest = hullPoints[0];
    foreach(ref p; hullPoints[1..$]){
        if (p.y < lowest.y || (p.y == lowest.y && p.x < lowest.x))
        {
            lowest = p;
        }
    }


    import std.algorithm.sorting : sort;

    hullPoints.sort!((Vec2d a, Vec2d b) {
    
        double thetaA = Math.atan2(a.y - lowest.y, a.x - lowest.x);
        double thetaB = Math.atan2(b.y - lowest.y, b.x - lowest.x);

        if (thetaA < thetaB)
        {
            return true;
        }

        if (thetaA > thetaB)
        {
            return false;
        }

        double distA = Math.sqrt(((lowest.x - a.x) * (lowest.x - a.x)) +
                (
                    (lowest.y - a.y) * (lowest.y - a.y)));
        double distB = Math.sqrt(((lowest.x - b.x) * (lowest.x - b.x)) +
                (
                    (lowest.y - b.y) * (lowest.y - b.y)));

        return distA < distB ? true : false;
    });

    if (Points.collinear(hullPoints))
    {
        return result;
    }

    import std.container.slist : SList;

    SList!Vec2d stack;
    stack.insert(hullPoints[0]);
    stack.insert(hullPoints[1]);

    for (int i = 2; i < hullPoints.length; i++)
    {
        Vec2d head = hullPoints[i];
        Vec2d middle = stack.front;
        stack.removeFront;
        Vec2d tail = stack.front;

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

    const stackLen = stack[].walkLength;

    //TODO more optimal
    import std.array: array;
    result = stack.array;
    
    return result;
}

unittest {
    import std.math.operations: isClose;
    Vec2d[] points = [Vec2d(1, 1), Vec2d(2, 2,), Vec2d(3, 2), Vec2d(3, 1), Vec2d(4, 3), Vec2d(1, 4), Vec2d(2, 3)];
    Vec2d[] res1 = grahamScan(points);
    Vec2d[] expected1 = [
        Vec2d(1, 1), 
        Vec2d(1, 4), 
        Vec2d(4, 3), 
        Vec2d(3, 1), 
        Vec2d(1, 1),
        ];
    assert(res1 == expected1);
}
