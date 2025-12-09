module api.math.geom2.circle2;

import api.math.geom2.vec2 : Vec2d;

/**
 * Authors: initkfs
 */
struct Circle2d
{
    float x = 0;
    float y = 0;
    float radius = 0;

    this(float x, float y, float radius){
        this.x = x;
        this.y = y;
        this.radius = radius;
    }

    this(Vec2d center, float radius){
        this(center.x, center.y, radius);
    }

    bool contains(float x1, float y1) const  nothrow pure @safe
    {
        //(x-centerX)^2 + (y - centerY)^2 < radius^2, or <=
        immutable dx = x - x1;
        immutable dy = y - y1;
        return dx * dx + dy * dy <= radius * radius;
    }

    bool contains(Vec2d p) const  nothrow pure @safe
    {
        return contains(p.x, p.y);
    }

    bool contains(Circle2d other) const  nothrow pure @safe
    {
        immutable deltaRadius = radius - other.radius;
        if (deltaRadius < 0.0)
        {
            return false;
        }

        immutable dx = x - other.x;
        immutable dy = y - other.y;

        immutable distanceSqr = dx * dx + dy * dy;
        immutable radiusAll = radius + other.radius;
        if (!(deltaRadius * deltaRadius < distanceSqr) && (distanceSqr < radiusAll * radiusAll))
        {
            return true;
        }

        return false;
    }

    bool intersect(Circle2d other) const  nothrow pure @safe
    {
        immutable dx = x - other.x;
        immutable dy = y - other.y;

        immutable distanceSqr = dx * dx + dy * dy;
        immutable radiusAll = radius + other.radius;

        return distanceSqr < radiusAll * radiusAll;
    }

    float circumference() const  nothrow pure @safe
    {
        import math = api.dm.math;

        return radius * (math.PI * 2);
    }

    Vec2d center() => Vec2d(x, y);

    float area() const  nothrow pure @safe
    {
        import math = api.dm.math;

        return radius * radius * math.PI;
    }

    string toString() const
    {
        import std.format : format;

        return format("x: %s, y: %s, radius: %s", x, y, radius);
    }
}
