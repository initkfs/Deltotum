module api.sims.phys.movings.physeffects;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.math.geom2.vec2 : Vec2f;
import Math = api.math;

/**
 * Authors: initkfs
 */

/** 
    springTo.updtate(dt, input.pointerPos);
 */
class SpringToSprite : SpringTo
{
    Sprite2d sprite;

    bool update(float dt, Vec2f toPoint)
    {
        if (!sprite)
        {
            return false;
        }
        super.update(dt, sprite.center, toPoint);

        sprite.x = sprite.x + vx;
        sprite.y = sprite.y + vy;
        return true;
    }
}

class SpringTo
{
    float spring = 3.5;
    float friction = 0.95;

    float vx = 0;
    float vy = 0;

    void update(float dt, Vec2f targetCenter, Vec2f toPoint)
    {
        auto dx = toPoint.x - targetCenter.x;
        auto dy = toPoint.y - targetCenter.y;

        vx += dx * spring * dt;
        vy += dy * spring * dt;

        vx *= friction;
        vy *= friction;
    }
}