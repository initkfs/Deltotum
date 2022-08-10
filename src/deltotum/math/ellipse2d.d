module deltotum.math.ellipse2d;

import deltotum.math.vector2d : Vector2D;

/**
 * Authors: initkfs
 */
struct Ellipse2D
{
    double x = 0;
    double y = 0;
    double width = 0;
    double height = 0;

    bool contains(double x1, double y1) const @nogc nothrow pure @safe
    {
        //https://math.stackexchange.com/questions/2114895/point-ellipse-collision-test
        immutable dx = x1 - x;
        immutable dy = y1 - y;
        return (dx * dx) / (width * 0.5 * width * 0.5) + (dy * dy) / (height * 0.5 * height * 0.5) <= 1.0;
    }

    bool contains(Vector2D p) const @nogc nothrow pure @safe
    {
        return contains(p.x, p.y);
    }

    double circumference() const @nogc nothrow pure @safe
    {
        import deltotum.math.math : Math;

        return Math.PI * (semiMajorAxis + semiMinorAxis);
    }

    double semiMajorAxis() const @nogc nothrow pure @safe
    {
        return width / 2;
    }

    double semiMinorAxis() const @nogc nothrow pure @safe
    {
        return height / 2;
    }

    double area() const @nogc nothrow pure @safe
    {
        import deltotum.math.math : Math;

        return Math.PI * semiMajorAxis * semiMinorAxis;
    }

    string toString() const
    {
        import std.format : format;

        return format("x: %s, y: %s, width: %s, height: %s", x, y, width, height);
    }
}
