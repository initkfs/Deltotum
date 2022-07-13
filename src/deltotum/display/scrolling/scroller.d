module deltotum.display.scrolling.scroller;

import deltotum.display.display_object : DisplayObject;
import deltotum.math.direction : Direction;

/**
 * Authors: initkfs
 */
class Scroller : DisplayObject
{
    @property double speed = 0;
    @property Direction direction = Direction.none;
    @property DisplayObject _current;
    @property DisplayObject _next;
    @property bool isScroll;

    override void drawContent()
    {
        //TODO check in bounds
        if (_current)
        {
            _current.draw;
        }
        if (_next)
        {
            _next.draw;
        }
    }

    override void update(double delta)
    {
        if (!isScroll)
        {
            return;
        }
        const double offset = speed * delta;
        final switch (direction)
        {
        case Direction.up:
            current.y -= offset;
            next.y -= offset;
            break;
        case Direction.down:
            current.y += offset;
            next.y += offset;
            break;
        case Direction.left:
            current.x -= offset;
            next.x -= offset;
            break;
        case Direction.right:
            current.x += offset;
            next.x += offset;
            break;
        case Direction.none:
            break;
        }

        auto worldBounds = window.getWorldBounds;
        if (direction == Direction.left && current.bounds.right <= 0)
        {
            auto mustBeNext = current;
            current = next;
            next = mustBeNext;
            next.x = worldBounds.right;
        }
    }

    @property DisplayObject current() @nogc nothrow
    {
        return _current;
    }

    @property void current(DisplayObject current)
    {
        import std.exception : enforce;

        enforce(current !is null, "Current sprite must not be null");
        _current = current;

    }

    @property DisplayObject next() @nogc nothrow
    {
        return _next;
    }

    @property void next(DisplayObject next)
    {
        import std.exception : enforce;

        enforce(next !is null, "Next sprite must not be null");
        _next = next;

        auto worldBounds = window.getWorldBounds;
        if (direction == Direction.left)
        {
            next.x = worldBounds.right;
        }
    }
}
