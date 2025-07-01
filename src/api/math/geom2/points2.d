module api.math.geom2.points2;

import api.math.geom2.vec2;

/**
 * Authors: initkfs
 */

enum PointsOrientation
{
    collinear,
    clockwise,
    counterClockwise,
}

bool collinear(Vec2d[] points) {

        if(points.length < 2) {
            return true;
        }

        Vec2d a = points[0];
        Vec2d b = points[1];

        foreach(ref c; points[2..$]){
            if(orientation(a, b, c) != PointsOrientation.collinear) {
                return false;
            }
        }

        return true;
    }

//https://stackoverflow.com/questions/1560492/how-to-tell-whether-a-point-is-to-the-right-or-left-side-of-a-line
PointsOrientation orientation(Vec2d a, Vec2d b, Vec2d c)
{
    //(b.x-a.x * c.y-a.y) - (b.y-a.y * c.x-a.x)
    const slope = ((b.x - a.x) * (c.y - a.y)) - ((b.y - a.y) * (c.x - a.x));

    if (slope == 0)
    {
        return PointsOrientation.collinear;
    }

    return (slope < 0) ? PointsOrientation.clockwise : PointsOrientation.counterClockwise;
}
