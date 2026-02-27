module api.math.geom2.rect2;

import api.math.geom2.vec2 : Vec2f;
import api.math.geom2.circle2 : Circle2f;
import api.math.pos2.position : Pos;

//TODO template from Rect2f
struct Rect2i
{
    int x;
    int y;
    int width;
    int height;
}

struct Rect2d
{
    double x = 0;
    double y = 0;
    double width = 0;
    double height = 0;
}

/**
 * Authors: initkfs
 */
struct Rect2f
{
    float x = 0;
    float y = 0;
    float width = 0;
    float height = 0;

    bool contains(float x, float y) const nothrow pure @safe
    {
        return x >= this.x && y >= this.y && x < right && y < bottom;
    }

    bool contains(Vec2f point) const nothrow pure @safe
    {
        return contains(point.x, point.y);
    }

    bool contains(Circle2f circle) const nothrow pure @safe
    {
        return (circle.x + circle.radius <= right) && (circle.x - circle.radius >= x) && (
            circle.y + circle.radius <= bottom) && (
            circle.y - circle.radius >= y);
    }

    bool contains(Rect2f rect) const nothrow pure @safe
    {
        return ((rect.x >= x && rect.x <= right) && (rect.right >= x && rect.right <= right))
            && ((rect.y >= y && rect.y <= bottom) && (rect.bottom >= y && rect.bottom <= bottom));
    }

    bool intersect(Rect2f other)
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

    bool intersect(Circle2f circle)
    {
        import Math = api.dm.math;

        float circleDistanceX = Math.abs(circle.x - x);
        float circleDistanceY = Math.abs(circle.y - y);

        const float halfWidth = width / 2.0;
        const float halfHeight = height / 2.0;

        if (circleDistanceX > (halfWidth + circle.radius) ||
            circleDistanceY > (halfHeight + circle.radius))
        {
            return false;
        }

        if (circleDistanceX <= halfWidth || circleDistanceY <= halfHeight)
        {
            return true;
        }

        float cornerDistance = (circleDistanceX - halfWidth) ^^ 2 +
            (
                circleDistanceY - halfHeight) ^^ 2;

        return (cornerDistance <= (circle.radius ^^ 2));
    }

    float halfWidth() const nothrow pure @safe => width / 2;
    float halfHeight() const nothrow pure @safe => height / 2;
    Vec2f halfSize() const nothrow pure @safe => Vec2f(halfWidth, halfHeight);

    float right() const nothrow pure @safe => x + width;
    float bottom() const nothrow pure @safe => y + height;

    float middleX() const nothrow pure @safe => x + halfWidth;
    float middleY() const nothrow pure @safe => y + halfHeight;

    Vec2f center() const nothrow pure @safe => Vec2f(middleX, middleY);
    Vec2f centerLeft() const nothrow pure @safe => Vec2f(x, middleY);
    Vec2f centerRight() const nothrow pure @safe => Vec2f(right, middleY);
    Vec2f topCenter() const nothrow pure @safe => Vec2f(middleX, y);
    Vec2f topLeft() const nothrow pure @safe => Vec2f(x, y);
    Vec2f topRight() const nothrow pure @safe => Vec2f(right, y);
    Vec2f bottomLeft() const nothrow pure @safe => Vec2f(x, bottom);
    Vec2f bottomRight() const nothrow pure @safe => Vec2f(right, bottom);
    Vec2f bottomCenter() const nothrow pure @safe => Vec2f(middleX, bottom);

    Vec2f toParentBoundsHalf(Rect2f parent, Pos pos) const nothrow pure @safe
    {
        Vec2f newPos;
        final switch (pos) with (Pos)
        {
            case topRight:
                newPos = parent.topRight.sub(halfSize);
                break;
            case topLeft:
                newPos = parent.topLeft.sub(halfSize);
                break;
            case topCenter:
                newPos = parent.topCenter.sub(halfSize);
                break;
            case centerLeft:
                newPos = parent.centerLeft.decXY(width, halfHeight);
                break;
            case center:
                newPos = parent.center.sub(halfSize);
                break;
            case centerRight:
                newPos = parent.centerRight;
                newPos.y -= halfHeight;
                break;
            case bottomLeft:
                newPos = parent.bottomLeft.sub(halfSize);
                break;
            case bottomCenter:
                newPos = parent.bottomCenter.sub(halfSize);
                break;
            case bottomRight:
                newPos = parent.bottomRight.sub(halfSize);
                break;
        }
        return newPos;
    }

    float aspectRatio() const nothrow pure @safe
    {
        import std.math.operations : isClose;

        if (height == 0)
        {
            return 0;
        }

        return width / height;
    }

    float diagonal() const nothrow pure @safe
    {
        import Math = api.math;

        //sqrt(a²+b²)
        auto v = Math.sqrt(Math.pow(width, 2) + Math.pow(height, 2));
        return v;
    }

    Rect2f withPadding(float value)
    {
        return Rect2f(x + value, y + value, width - value, height - value);
    }

    Rect2f boundingBoxMax()
    {
        const diag = diagonal;
        return Rect2f(x, y, diag, diag);
    }

    Rect2f boundingBox(float angleDeg)
    {
        import Math = api.math;

        auto newH = width * Math.abs(Math.sinDeg(angleDeg)) + height * Math.abs(
            Math.cosDeg(angleDeg));
        auto newW = width * Math.abs(Math.cosDeg(angleDeg)) + height * Math.abs(
            Math.sinDeg(angleDeg));
        return Rect2f(0, 0, newW, newH);
    }

    Vec2f pos() => Vec2f(x, y);

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

    Rect2f rect1 = Rect2f(10, 10, w, h);

    assert(rect1.intersect(rect1));
    assert(rect1.intersect(Rect2f(0, 0, w, h)));

    assert(rect1.intersect(Rect2f(10, 0, w, h)));
    assert(rect1.intersect(Rect2f(0, 10, w, h)));

    assert(rect1.intersect(Rect2f(20, 0, w, h)));
    assert(rect1.intersect(Rect2f(20, 10, w, h)));

    assert(rect1.intersect(Rect2f(20, 20, w, h)));
    assert(rect1.intersect(Rect2f(10, 20, w, h)));

    //overlap
    assert(rect1.intersect(Rect2f(0, 0, w * 3, h * 3)));
    assert(rect1.intersect(Rect2f(10, 0, w, h * 2)));

    assert(!rect1.intersect(Rect2f(0, 0, w - 1, h - 1)));

    assert(!rect1.intersect(Rect2f(10, 0, w, h - 1)));
    assert(!rect1.intersect(Rect2f(0, 10, w - 1, h)));

    assert(!rect1.intersect(Rect2f(20 + 1, 0, w, h)));
    assert(!rect1.intersect(Rect2f(20 + 1, 10, w, h)));

    assert(!rect1.intersect(Rect2f(20, 20 + 1, w, h)));
    assert(!rect1.intersect(Rect2f(10, 20 + 1, w, h)));
}
