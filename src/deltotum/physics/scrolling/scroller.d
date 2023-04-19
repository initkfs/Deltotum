module deltotum.physics.scrolling.scroller;

import deltotum.toolkit.display.display_object : DisplayObject;
import deltotum.physics.direction : Direction;

/**
 * Authors: initkfs
 */
class Scroller : DisplayObject
{
    double speed = 0;
    Direction direction = Direction.none;
    DisplayObject _current;
    DisplayObject _next;
    bool isScroll;

    this(){
        super();
        isRedrawChildren = false;
    }

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
        if (current)
        {
            current.update(delta);
        }

        //TODO check in bounds
        if (next)
        {
            next.update(delta);
        }

        if (!isScroll)
        {
            return;
        }
        const double offset = speed * delta;
        final switch (direction)
        {
        case Direction.up:
            current.y = current.y - offset;
            next.y = next.y - offset;
            break;
        case Direction.down:
            current.y = current.y + offset;
            next.y = next.y + offset;
            break;
        case Direction.left:
            current.x = current.x - offset;
            next.x = next.x - offset;
            break;
        case Direction.right:
            current.x = current.x + offset;
            next.x = next.x + offset;
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

    DisplayObject current() @nogc nothrow
    {
        return _current;
    }

    void current(DisplayObject current)
    {
        import std.exception : enforce;

        enforce(current !is null, "Current sprite must not be null");
        _current = current;
        add(current);
    }

    DisplayObject next() @nogc nothrow
    {
        return _next;
    }

    void next(DisplayObject next)
    {
        import std.exception : enforce;

        enforce(next !is null, "Next sprite must not be null");
        _next = next;

        auto worldBounds = window.getWorldBounds;
        if (direction == Direction.left)
        {
            next.x = worldBounds.right;
        }

        add(next);
    }
}
