module api.math.geom2.line2;

import api.math.geom2.vec2 : Vec2d;

/**
 * Authors: initkfs
 */
struct Line2d
{
    Vec2d start;
    Vec2d end;

    this(Vec2d newStart, Vec2d newEnd) pure @nogc @safe
    {
        this.start = newStart;
        this.end = newEnd;
    }

    this(double x0, double y0, double x1, double y1) pure @nogc @safe
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
}
