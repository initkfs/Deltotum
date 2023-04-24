module deltotum.math.shapes.circle2d;

import deltotum.math.vector2d : Vector2d;

/**
 * Authors: initkfs
 */
struct Circle2d
{
    double x = 0;
    double y = 0;
    double radius = 0;

    bool contains(double x1, double y1) const @nogc nothrow pure @safe
    {
        //(x-centerX)^2 + (y - centerY)^2 < radius^2, or <=
        immutable dx = x - x1;
        immutable dy = y - y1;
        return dx * dx + dy * dy <= radius * radius;
    }

    bool contains(Vector2d p) const @nogc nothrow pure @safe
    {
        return contains(p.x, p.y);
    }

    bool contains(Circle2d other) const @nogc nothrow pure @safe
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

    bool overlaps(Circle2d other) const @nogc nothrow pure @safe
    {
        immutable dx = x - other.x;
        immutable dy = y - other.y;

        immutable distanceSqr = dx * dx + dy * dy;
        immutable radiusAll = radius + other.radius;

        return distanceSqr < radiusAll * radiusAll;
    }

    double circumference() const @nogc nothrow pure @safe
    {
        import math = deltotum.math;

        return radius * (math.PI * 2);
    }

    double area() const @nogc nothrow pure @safe
    {
        import math = deltotum.math;

        return radius * radius * math.PI;
    }

    string toString() const
    {
        import std.format : format;

        return format("x: %s, y: %s, radius: %s", x, y, radius);
    }
}
