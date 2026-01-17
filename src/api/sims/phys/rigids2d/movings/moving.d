module api.sims.phys.rigids2d.movings.moving;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.math.geom2.vec2 : Vec2f;
import api.math.geom2.line2 : Line2f;
import api.dm.kit.sprites2d.textures.vectors.shapes.vcircle : VCircle;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.graphics.colors.rgba : RGBA;
import Math = api.math;

/**
 * Authors: initkfs
 */

class AngleBounce : Sprite2d
{
    float bounce = -0.5;

    Line2f line;
    float angleDeg = 45;

    Sprite2d ball;

    override void create()
    {
        super.create;

        line = Line2f.fromAngleDeg(Vec2f(0, 200), angleDeg, 400);

        ball = new VCircle(20);
        ball.pos = Vec2f(10, 0);
        addCreate(ball);

        ball.gravity = 1;
        ball.isDraggable = true;
        ball.onPointerRelease ~= (ref e) { ball.isPhysics = true; };

    }

    override void drawContent()
    {
        import api.dm.kit.graphics.colors.rgba : RGBA;

        graphic.color = RGBA.lightcoral;
        scope (exit)
        {
            graphic.restoreColor;
        }
        graphic.line(line);
    }

    override void update(float dt)
    {
        super.update(dt);

        const spriteBounds = ball.boundsRect;
        const bounds = graphic.renderBounds;

        if (spriteBounds.right > bounds.right)
        {
            ball.x = bounds.right - spriteBounds.width;
            ball.velocity.x *= bounce;
        }
        else if (spriteBounds.x < 0)
        {
            ball.x = 0;
            ball.velocity.x *= bounce;
        }
        if (spriteBounds.bottom > bounds.bottom)
        {
            ball.y = bounds.bottom;
            ball.velocity.y *= bounce;
        }
        else if (ball.y < 0)
        {
            ball.y = 0;
            ball.velocity.y *= bounce;
        }

        if (ball.x > line.start.x && ball.x < line.end.x)
        {
            auto cos = Math.cosDeg(angleDeg);
            auto sin = Math.sinDeg(angleDeg);

            auto x1 = ball.x - line.start.x;
            auto y1 = ball.y - line.start.y;

            // rotate coordinates
            auto y2 = cos * y1 - sin * x1;

            //rotate velocity
            auto vy1 = cos * ball.velocity.y - sin * ball.velocity.x;

            if (y2 > -ball.height / 2 && y2 < vy1)
            {
                auto x2 = cos * x1 + sin * y1;
                auto vx1 = cos * ball.velocity.x + sin * ball.velocity.y;

                if (y2 > -ball.height / 2)
                {
                    y2 = -ball.height / 2;
                    vy1 *= bounce;
                }

                x1 = cos * x2 - sin * y2;
                y1 = cos * y2 + sin * x2;
                ball.x = line.start.x + x1;
                ball.y = line.start.y + y1;

                ball.velocity = Vec2f(cos * vx1 - sin * vy1, cos * vy1 + sin * vx1);

            }

        }

    }

}

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

class EasingTo : Sprite2d
{
    float easing = 0.2;
    Vec2f target;
    bool isMove;

    override void update(float dt)
    {
        super.update(dt);

        if (!isMove)
        {
            return;
        }

        foreach (sprite; children)
        {
            const dist = target.sub(sprite.pos);

            const dx = dist.x * easing;
            const dy = dist.y * easing;

            sprite.acceleration.x = dx;
            sprite.acceleration.y = dy;
        }
    }
}
