module api.math.geom2.line2;

import api.math.geom2.vec2 : Vec2d;

import Math = api.math;

/**
 * Authors: initkfs
 */
struct Line2d
{
    Vec2d start;
    Vec2d end;

    this(Vec2d newStart, Vec2d newEnd) pure  @safe
    {
        this.start = newStart;
        this.end = newEnd;
    }

    this(double x0, double y0, double x1, double y1) pure  @safe
    {
        start = Vec2d(x0, y0);
        end = Vec2d(x1, y1);
    }

    Vec2d midpoint()
    {
        const midx = (start.x + end.x) / 2;
        const midy = (start.y + end.y) / 2;
        return Vec2d(midx, midy);
    }

    double angle()
    {
        const ax = end.x - start.x;
        const ay = end.y - start.y;

        return Math.atan2(ay, ax);
    }

    //https://stackoverflow.com/questions/849211/shortest-distance-between-a-point-and-a-line-segment
    double distanceToSquared(Vec2d point)
    {
        if (point == start || point == end)
        {
            return 0;
        }

        const a = point.x - start.x;
        const b = point.y - start.y;
        const c = end.x - start.x;
        const d = end.y - start.y;

        const dot = a * c + b * d;
        const lenSquare = c * c + d * d;
        double param = -1;
        if (lenSquare != 0)
        {
            param = dot / lenSquare;
        }

        double xx = 0, yy = 0;

        if (param < 0)
        {
            xx = start.x;
            yy = start.y;
        }
        else if (param > 1)
        {
            xx = end.x;
            yy = end.y;
        }
        else
        {
            xx = start.x + param * c;
            yy = start.y + param * d;
        }

        const dx = point.x - xx;
        const dy = point.y - yy;
        return dx * dx + dy * dy;
    }

    double lengthSquared()
    {

        const dx = end.x - start.x;
        const dy = end.y - start.y;

        return dx * dx + dy * dy;
    }

    double length() => Math.sqrt(lengthSquared);

    double distanceTo(Vec2d point) => Math.sqrt(distanceToSquared(point));

    unittest
    {
        import std.math.operations : isClose;

        Line2d line1 = Line2d(10, 15, 45, 60);
        Vec2d p1 = Vec2d(17, 23);
        assert(isClose(line1.distanceTo(p1), 0.61394061351));
    }

    double x1(double y1)
    {

        if (start.y == y1)
        {
            return start.x;
        }

        if (end.y == y1)
        {
            return end.x;
        }

        const dy = end.y - start.y;
        if (dy == 0)
        {
            return double.infinity;
        }

        const dx = end.x - start.x;
        if (dx == 0)
        {
            return double.infinity;
        }

        return (start.x + ((y1 - start.y) * dx / dy));
    }

    double y1(double x1)
    {
        if (start.x == x1)
        {
            return start.y;
        }

        if (end.x == x1)
        {
            return end.y;
        }

        const dx = end.x - start.x;
        if (dx == 0)
        {
            return double.infinity;
        }

        const dy = end.y - start.y;
        if (dy == 0)
        {
            return double.infinity;
        }

        return (start.y + ((x1 - start.x) * dy / dx));
    }

    bool onOneLine(Vec2d a, Vec2d b, Vec2d c)
    {
        import Math = api.math;

        if (
            (b.x <= Math.max(a.x, c.x)) &&
            (b.x >= Math.min(a.x, c.x)) &&
            (b.y <= Math.max(a.y, c.y)) &&
            (b.y >= Math.min(a.y, c.y))
            )
            return true;

        return false;
    }

    bool intersect(Line2d other)
    {
        import Points = api.math.geom2.points2;

        const onLine1 = onOneLine(start, end, other.start);
        const onLine2 = onOneLine(start, end, other.end);
        const onLine3 = onOneLine(other.start, other.end, start);
        const onLine4 = onOneLine(other.start, other.end, end);

        if (
            (onLine1 != onLine2 && onLine3 != onLine4) ||
            (onLine1 == Points.PointsOrientation.collinear && onOneLine(start, other.start, end)) ||
            (onLine2 == Points.PointsOrientation.collinear && onOneLine(start, other.end, end)) ||
            (onLine3 == Points.PointsOrientation.collinear && onOneLine(other.start, start, other
                .end)) ||
            (onLine4 == Points.PointsOrientation.collinear && onOneLine(other.start, end, other.end))
            )
        {
            return true;
        }

        return false;
    }

    //http://thirdpartyninjas.com/blog/2008/10/07/line-segment-intersection/
    bool intersect2(Line2d other)
    {
        const denom = (other.end.y - other.start.y) * (end.x - start.x) - (
            other.end.x - other.start.x) * (end.y - start.y);

        if (denom != 0)
        {
            const ua = ((other.end.x - other.start.x) * (
                    start.y - other.start.y) - (
                    other.end.y - other.start.y) * (
                    start.x - other.start.x)) / denom;
            const ub = ((end.x - start.x) * (start.y - other.start.y) - (
                    end.y - start.y) * (start.x - other.start.x)) / denom;

            bool isIncludeEnd = true;
            if (isIncludeEnd)
            {
                if (ua >= 0 && ua <= 1 && ub >= 0 && ub <= 1)
                {
                    return true;
                }
            }
            else
            {
                if (ua > 0 && ua < 1 && ub > 0 && ub < 1)
                {
                    return true;
                }
            }
        }

        return false;
    }

    /** 
     * Port from https://www.habrador.com/tutorials/math/9-useful-algorithms/
     * under MIT license https://github.com/Habrador/Computational-geometry/blob/master/LICENSE
     */
    Vec2d intersectWith(Line2d other)
    {
        const denom = (other.end.y - other.start.y) * (end.x - start.x) - (
            other.end.x - other.start.x) * (end.y - start.y);

        const ua = ((other.end.x - other.start.x) * (start.y - other.start.y) - (
                other.end.y - other.start.y) * (start.x - other.start.x)) / denom;

        Vec2d intersect = start.add(end.subtract(start).scale(ua));

        return intersect;
    }

    bool isZero() const  pure @safe
    {
        return start == end;
    }
}
