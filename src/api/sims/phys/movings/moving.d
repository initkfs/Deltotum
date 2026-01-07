module api.sims.phys.movings.moving;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.math.geom2.vec2 : Vec2f;
import Math = api.math;

/**
 * Authors: initkfs
 */

class UpDown
{
    Sprite2d sprite;

    float centerY = 100;
    float rangeY = 50;
    float speed = 2.5;

    float angleRad = 0;
    float vy = 0;

    void update(float dt)
    {
        angleRad += speed * dt;
        sprite.y = centerY + Math.sin(angleRad) * rangeY;
    }
}

class LinearCircular
{
    Sprite2d sprite;

    Vec2f center;
    Vec2f radius = Vec2f(20, 20);
    float speed = 3;

    float angleRad = 0;

    void update(float dt)
    {
        angleRad += speed * dt;

        sprite.x = center.x + Math.sin(angleRad) * radius.x;
        sprite.y = center.y + Math.cos(angleRad) * radius.y;
    }
}

class WaveMotion
{
    Sprite2d sprite;

    float centerY = 100;
    float rangeY = 100;
    Vec2f speed = Vec2f(100, 5);

    float angleRad = 0;

    void update(float dt)
    {
        angleRad += speed.y * dt;

        sprite.x = sprite.x + speed.x * dt;
        sprite.y = centerY + Math.sin(angleRad) * rangeY;
    }
}

class RandomAngleMotion
{
    Sprite2d sprite;

    Vec2f center = Vec2f(100, 100);
    Vec2f speed = Vec2f(5, 10);
    float range = 50;

    Vec2f angleRad;

    void update(float dt)
    {
        angleRad.x += speed.x * dt;
        angleRad.y += speed.y * dt;

        sprite.x = center.x + Math.sin(angleRad.x) * range;
		sprite.y = center.y + Math.sin(angleRad.y) * range;
		
    }
}
