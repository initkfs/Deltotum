module deltotum.core.maths.shapes.rect2d;

import deltotum.core.maths.vector2d : Vector2d;
import deltotum.core.maths.shapes.circle2d : Circle2d;

/**
 * Authors: initkfs
 */
struct Rect2d
{
    double x = 0;
    double y = 0;
    double width = 0;
    double height = 0;

    bool contains(double x, double y) const @nogc nothrow pure @safe
    {
        return x >= this.x && y >= this.y && x < right && y < bottom;
    }

    bool contains(Vector2d point) const @nogc nothrow pure @safe
    {
        return contains(point.x, point.y);
    }

    bool contains(Circle2d circle) const @nogc nothrow pure @safe
    {
        return (circle.x + circle.radius <= right) && (circle.x - circle.radius >= x) && (
            circle.y + circle.radius <= bottom) && (
            circle.y - circle.radius >= y);
    }

    bool contains(Rect2d rect) const @nogc nothrow pure @safe
    {
        float minX = rect.x;
        float maxX = right;

        float minY = rect.y;
        float maxY = bottom;

        return ((minX > x && minX < right) && (maxX > x && maxX < right))
            && ((minY > y && minY < bottom) && (maxY > y && maxY < bottom));
    }

    bool overlaps(Rect2d other) const @nogc nothrow pure @safe
    {
        auto isOverlaps = (other.right > x) && (other.x < right) && (other.bottom > y) && (
            other.y < bottom);
        return isOverlaps;
    }

    double right() const @nogc nothrow pure @safe
    {
        return x + width;
    }

    double bottom() const @nogc nothrow pure @safe
    {
        return y + height;
    }

    double halfWidth() const @nogc nothrow pure @safe
    {
        return width / 2;
    }

    double middleX() const @nogc nothrow pure @safe
    {
        return x + halfWidth;
    }

    double middleY() const @nogc nothrow pure @safe
    {
        return y + halfHeight;
    }

    double halfHeight() const @nogc nothrow pure @safe
    {
        return height / 2;
    }

    Vector2d minPoint() const @nogc nothrow pure @safe
    {
        Vector2d minXPos = {x, y};
        return minXPos;
    }

    Vector2d maxPoint() const @nogc nothrow pure @safe
    {
        Vector2d maxYPos = {right, bottom};
        return maxYPos;
    }

    Vector2d center() const @nogc nothrow pure @safe
    {
        return Vector2d(x + halfWidth, y + halfHeight);
    }

    double aspectRatio() const @nogc nothrow pure @safe
    {
        import std.math.operations : isClose;

        if (height == 0)
        {
            return 0;
        }

        return width / height;
    }

    string toString() const
    {
        import std.format : format;

        return format("x: %s, y: %s, width: %s, height: %s", x, y, width, height);
    }

}
