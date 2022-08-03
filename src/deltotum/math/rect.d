module deltotum.math.rect;

import deltotum.math.vector2d : Vector2D;

/**
 * Authors: initkfs
 */
struct Rect
{
    double x = 0;
    double y = 0;
    double width = 0;
    double height = 0;

    bool overlaps(Rect other) const @nogc nothrow pure @safe
    {
        auto isOverlaps = (other.right > x) && (other.x < right) && (other.bottom > y) && (
            other.y < bottom);
        return isOverlaps;
    }

    bool contains(double x, double y) const @nogc nothrow pure @safe
    {
        return x >= this.x && y >= this.y && x < right && y < bottom;
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

    Vector2D minPoint() const @nogc nothrow pure @safe
    {
        Vector2D minXPos = {x, y};
        return minXPos;
    }

    Vector2D maxPoint() const @nogc nothrow pure @safe
    {
        Vector2D maxYPos = {right, bottom};
        return maxYPos;
    }

}
