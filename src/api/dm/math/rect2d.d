module api.dm.math.rect2d;

import api.dm.math.vector2 : Vector2;
import api.dm.math.circle2d : Circle2d;

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

    bool contains(Vector2 point) const @nogc nothrow pure @safe
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
        return ((rect.x > x && rect.x < right) && (rect.right > x && rect.right < right))
            && ((rect.y > y && rect.y < bottom) && (rect.bottom > y && rect.bottom < bottom));
    }

    bool intersect(Rect2d other)
    {
        // auto isOverlaps = (other.right > x) && (other.x < right) && (other.bottom > y) && (
        //    other.y < bottom);

        //Separating Axis Theorem
        if (right < other.x || x > other.right)
        {
            return false;
        }
        if (bottom < other.y || y > other.bottom)
        {
            return false;
        }

        return true;
    }

    bool intersect(Circle2d circle)
    {
        import Math = api.dm.math;

        double circleDistanceX = Math.abs(circle.x - x);
        double circleDistanceY = Math.abs(circle.y - y);

        const double halfWidth = width / 2.0;
        const double halfHeight = height / 2.0; 

        if (circleDistanceX > (halfWidth + circle.radius) || 
        circleDistanceY > (halfHeight + circle.radius))
        {
            return false;
        }

        if (circleDistanceX <= halfWidth || circleDistanceY <= halfHeight)
        {
            return true;
        }

        double cornerDistance = (circleDistanceX - halfWidth) ^^ 2 +
            (
                circleDistanceY - halfHeight) ^^ 2;

        return (cornerDistance <= (circle.radius ^^ 2));
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

    Vector2 center() const @nogc nothrow pure @safe
    {
        return Vector2(middleX, middleY);
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

        return format("x: %s, y: %s, w: %s, h: %s", x, y, width, height);
    }

}

unittest
{
    enum w = 10;
    enum h = 10;

    Rect2d rect1 = Rect2d(10, 10, w, h);

    assert(rect1.intersect(rect1));
    assert(rect1.intersect(Rect2d(0, 0, w, h)));

    assert(rect1.intersect(Rect2d(10, 0, w, h)));
    assert(rect1.intersect(Rect2d(0, 10, w, h)));

    assert(rect1.intersect(Rect2d(20, 0, w, h)));
    assert(rect1.intersect(Rect2d(20, 10, w, h)));

    assert(rect1.intersect(Rect2d(20, 20, w, h)));
    assert(rect1.intersect(Rect2d(10, 20, w, h)));

    //overlap
    assert(rect1.intersect(Rect2d(0, 0, w * 3, h * 3)));
    assert(rect1.intersect(Rect2d(10, 0, w, h * 2)));

    assert(!rect1.intersect(Rect2d(0, 0, w - 1, h - 1)));

    assert(!rect1.intersect(Rect2d(10, 0, w, h - 1)));
    assert(!rect1.intersect(Rect2d(0, 10, w - 1, h)));

    assert(!rect1.intersect(Rect2d(20 + 1, 0, w, h)));
    assert(!rect1.intersect(Rect2d(20 + 1, 10, w, h)));

    assert(!rect1.intersect(Rect2d(20, 20 + 1, w, h)));
    assert(!rect1.intersect(Rect2d(10, 20 + 1, w, h)));
}
