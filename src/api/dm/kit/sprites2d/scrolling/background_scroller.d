module api.dm.kit.sprites2d.scrolling.background_scroller;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.math.geom2.rect2 : Rect2d;

enum Direction
{
    none,
    up,
    down,
    left,
    right
}

/**
 * Authors: initkfs
 */
class BackgroundScroller : Sprite2d
{
    float speed = 10;
    Direction direction = Direction.left;
    Sprite2d _current;
    Sprite2d _next;
    bool isScroll;

    float seamОffset = 0;

    Rect2d delegate() worldBoundsProvider;

    this(Direction direction, Rect2d delegate() worldBoundsProvider = null)
    {
        super();
        this.direction = direction;
        //isRedrawChildren = false;
        this.worldBoundsProvider = worldBoundsProvider;
    }

    override void create()
    {
        super.create;
        if (!worldBoundsProvider)
        {
            worldBoundsProvider = () { return graphic.renderBounds; };
        }
    }

    override void update(float delta)
    {
        super.update(delta);

        if (!isScroll)
        {
            return;
        }

        const float offset = speed * delta;

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

        auto worldBounds = worldBoundsProvider();

        //TODO all directions
        if (direction == Direction.down && _current.boundsRect.y >= worldBounds.bottom)
        {
            auto mustBePrev = _current;
            _current = _next;
            _next = mustBePrev;
            setNextPos(_next);
        }
    }

    Sprite2d current()  nothrow
    {
        return _current;
    }

    void current(Sprite2d current)
    {
        import std.exception : enforce;

        current.isLayoutManaged = false;

        enforce(current !is null, "Current sprite must not be null");
        _current = current;
        addCreate(current);
        setCurrentPos(_current);
    }

    Sprite2d next()  nothrow
    {
        return _next;
    }

    void next(Sprite2d next)
    {
        import std.exception : enforce;

        next.isLayoutManaged = false;

        enforce(next !is null, "Next sprite must not be null");
        _next = next;

        addCreate(next);
        setNextPos(next);
    }

    protected void setCurrentPos(Sprite2d curr)
    {
        auto worldBounds = worldBoundsProvider();
        curr.x = worldBounds.x;
        curr.y = worldBounds.y;
    }

    protected void setNextPos(Sprite2d next)
    {
        auto worldBounds = worldBoundsProvider();
        if (direction == Direction.right)
        {
            next.x = worldBounds.x - next.width;
            next.y = worldBounds.y;
        }
        else if (direction == Direction.left)
        {
            next.x = worldBounds.right;
            next.y = worldBounds.y;
        }
        else if (direction == Direction.down)
        {
            next.x = worldBounds.x;
            next.y = worldBounds.y - next.height + seamОffset;
        }
    }
}
