module api.sims.phys.movings.boundaries;

/**
 * Authors: initkfs
 */

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.math.geom2.rect2 : Rect2f;
import api.math.geom2.vec2 : Vec2f;
import Math = api.math;

bool inOutOfBoundsFull(Sprite2d sprite, Rect2f bounds)
{
    const spriteBounds = sprite.boundsRect;

    if (spriteBounds.x > bounds.right || spriteBounds.y > bounds.bottom || spriteBounds.right < bounds.x || spriteBounds
        .bottom < bounds.y)
    {
        return true;
    }

    return false;
}

bool wrapOutOfBounds(Sprite2d sprite, Rect2f bounds)
{
    const spriteBounds = sprite.boundsRect;

    Vec2f newPos = sprite.pos;
    bool wrapped;

    if (spriteBounds.right < bounds.x)
    {
        newPos.x = bounds.right;
        wrapped = true;
    }

    else if (spriteBounds.x > bounds.right)
    {
        newPos.x = bounds.x - spriteBounds.width;
        wrapped = true;
    }

    else if (spriteBounds.x < bounds.x && spriteBounds.right > bounds.x)
    {
        newPos.x = bounds.right - (bounds.x - spriteBounds.x);
        wrapped = true;
    }

    else if (spriteBounds.x < bounds.right && spriteBounds.right > bounds.right)
    {
        newPos.x = bounds.x + (spriteBounds.right - bounds.right);
        wrapped = true;
    }

    if (spriteBounds.bottom < bounds.y)
    {
        newPos.y = bounds.bottom;
        wrapped = true;
    }
    else if (spriteBounds.y > bounds.bottom)
    {
        newPos.y = bounds.y - spriteBounds.height;
        wrapped = true;
    }
    else if (spriteBounds.y < bounds.y && spriteBounds.bottom > bounds.y)
    {
        newPos.y = bounds.bottom - (bounds.y - spriteBounds.y);
        wrapped = true;
    }
    else if (spriteBounds.y < bounds.bottom && spriteBounds.bottom > bounds.bottom)
    {
        newPos.y = bounds.y + (spriteBounds.bottom - bounds.bottom);
        wrapped = true;
    }

    if (!wrapped)
    {
        const boundsWidth = bounds.width;
        const boundsHeight = bounds.height;

        float relX = newPos.x - bounds.x;
        float relY = newPos.y - bounds.y;

        relX = relX - boundsWidth * Math.floor(relX / boundsWidth);
        relY = relY - boundsHeight * Math.floor(relY / boundsHeight);

        newPos.x = bounds.x + relX - spriteBounds.width * 0.5f;
        newPos.y = bounds.y + relY - spriteBounds.height * 0.5f;
    }

    sprite.pos = newPos;

    return wrapped;
}
