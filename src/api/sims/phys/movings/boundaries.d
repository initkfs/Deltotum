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

void wrapSimple(Sprite2d sprite, Rect2f bounds)
{
    const spriteBounds = sprite.boundsRect;

    float newX = sprite.pos.x;
    float newY = sprite.pos.y;

    if (spriteBounds.right < bounds.x)
    {
        sprite.x = bounds.right;
    }
    else if (spriteBounds.x > bounds.right)
    {
        sprite.x = bounds.x - spriteBounds.width;
    }

    if (spriteBounds.bottom < bounds.y)
    {
        sprite.y = bounds.bottom;
    }else if (spriteBounds.y > bounds.bottom)
    {
        sprite.y = bounds.y - spriteBounds.height;
    }
}
