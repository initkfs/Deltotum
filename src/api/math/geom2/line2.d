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
}
