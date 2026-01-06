module api.sims.phys.movings.moving;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.math.geom2.vec2 : Vec2f;
import Math = api.math;

/**
 * Authors: initkfs
 */

/** 
 *  springTo.toPoint = input.pointerPos;
    springTo.updtate(dt);
 */
class SpringToSprite : SpringTo
{
    Sprite2d sprite;

    void update(float dt)
    {
        if (!sprite)
        {
            return;
        }
        super.update(sprite.center, dt);

        sprite.x = sprite.x + vx;
        sprite.y = sprite.y + vy;
    }
}

class SpringTo
{
    Vec2f toPoint;

    float spring = 3.5;
    float vx = 0;
    float vy = 0;
    float friction = 0.95;

    void update(Vec2f targetCenter, float dt)
    {
        auto dx = toPoint.x - targetCenter.x;
        auto dy = toPoint.y - targetCenter.y;

        vx += dx * spring * dt;
        vy += dy * spring * dt;

        vx *= friction;
        vy *= friction;
    }
}
