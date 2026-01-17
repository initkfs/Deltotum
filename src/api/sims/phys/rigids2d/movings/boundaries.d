module api.sims.phys.rigids2d.movings.boundaries;

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

bool wrapBounds(Sprite2d sprite, Rect2f bounds)
{
    const spriteBounds = sprite.boundsRect;

    bool isWrap;

    if (spriteBounds.right < bounds.x)
    {
        sprite.x = bounds.right;
        isWrap |= true;
    }
    else if (spriteBounds.x > bounds.right)
    {
        sprite.x = bounds.x - spriteBounds.width;
        isWrap |= true;
    }

    if (spriteBounds.bottom < bounds.y)
    {
        sprite.y = bounds.bottom;
        isWrap |= true;
    }
    else if (spriteBounds.y > bounds.bottom)
    {
        sprite.y = bounds.y - spriteBounds.height;
        isWrap |= true;
    }

    return isWrap;
}

bool throwingBounds(Sprite2d sprite, Rect2f bounds, float bounce = -0.7)
{
    const spriteBounds = sprite.boundsRect;
    bool isWrap;

    if (spriteBounds.right > bounds.right)
    {
        sprite.x = bounds.right - spriteBounds.width;
        sprite.velocity.x *= bounce;
        isWrap |= true;
    }
    else if (spriteBounds.x < bounds.x)
    {
        sprite.x = bounds.x;
        sprite.velocity.x *= bounce;
        isWrap |= true;
    }

    if (spriteBounds.bottom > bounds.bottom)
    {
        sprite.y = bounds.bottom - spriteBounds.height;
        sprite.velocity.y *= bounce;
        isWrap |= true;
    }
    else if (spriteBounds.y < bounds.y)
    {
        sprite.y = bounds.y;
        sprite.velocity.y *= bounce;
        isWrap |= true;
    }

    return isWrap;
}
