module api.sims.phys.movings.physeffects;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.textures.vectors.shapes.vcircle : VCircle;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.geom2.vec2 : Vec2f;
import Math = api.math;

/**
 * Authors: initkfs
 */

/** 
    springTo.updtate(dt, input.pointerPos);
 */

class TripleSpring : Sprite2d
{
    float spring = 10;
    float springLength = 100;
    float friction = 0.95;

    Sprite2d ball0;
    Sprite2d ball1;
    Sprite2d ball2;

    override void create()
    {
        super.create;

        ball0 = createTarget;
        ball0.pos = Vec2f(101, 100);
       
        ball1 = createTarget;
        ball1.pos = Vec2f(205, 103);
        
        ball2 = createTarget;
        ball2.pos = Vec2f(150, 201);
        addCreate([ball0, ball1, ball2]);
    }

    protected Sprite2d createTarget() {
        auto target = new VCircle(20, GraphicStyle(5, RGBA.random, true, RGBA.random));
        target.isDraggable = true;
        target.isPhysics = true;
        target.friction = friction;
        return target;
    }

    override void drawContent(){
        graphic.color = RGBA.lightcyan;
        graphic.line(ball0.center, ball1.center);
        graphic.line(ball1.center, ball2.center);
        graphic.line(ball2.center, ball0.center);
    }

    override void update(float dt)
    {
        super.update(dt);

        if (!ball0.isDrag)
        {
            ball0.acceleration = springTo(ball0, ball1, dt).add(springTo(ball0, ball2, dt));
        }

        if (!ball1.isDrag)
        {
            ball1.acceleration = springTo(ball1, ball0, dt).add(springTo(ball1, ball2, dt));
        }

        if (!ball2.isDrag)
        {
            ball2.acceleration = springTo(ball2, ball0, dt).add(springTo(ball2, ball1, dt));
        }
    }

    Vec2f springTo(Sprite2d ballA, Sprite2d ballB, float dt)
    {
        auto dxdx = ballB.center.sub(ballA.center);
        auto angleRad = Math.atan2(dxdx.y, dxdx.x);

        const targetX = ballB.x - Math.cos(angleRad) * springLength;
        const targetY = ballB.y - Math.sin(angleRad) * springLength;

        return Vec2f((targetX - ballA.x) * spring * dt, (targetY - ballA.y) * spring * dt);
    }
}

class OffsetSpring : Sprite2d
{
    float spring = 2;
    float springLen = 100;

    Sprite2d sprite;

    override void create()
    {
        super.create;

        sprite = new VCircle(25, GraphicStyle(5, RGBA.randomLight, true, RGBA.randomLight));
        sprite.isDraggable = true;
        sprite.friction = 9;
        sprite.isPhysics = true;
        addCreate(sprite);
    }

    override bool draw(float at)
    {
        super.draw(at);

        import api.dm.kit.graphics.colors.rgba : RGBA;

        graphic.color = RGBA.lightcoral;
        graphic.line(input.pointerPos, sprite.center);
        return true;
    }

    override void update(float dt)
    {
        super.update(dt);

        Vec2f dxdy = sprite.pos.sub(input.pointerPos);
        auto angle = Math.atan2(dxdy);
        auto targetX = input.pointerPos.x + Math.cos(angle) * springLen;
        auto targetY = input.pointerPos.y + Math.sin(angle) * springLen;

        sprite.acceleration = Vec2f((targetX - sprite.x) * spring * dt, (targetY - sprite.y) * spring * dt);
    }
}

class MultiSpring : Sprite2d
{
    float spring = 2;

    Sprite2d[] handles;
    Sprite2d sprite;

    override void create()
    {
        super.create;

        float nextX = 100, nextY = 100;
        foreach (i; 0 .. 3)
        {
            auto handle = new VCircle(25, GraphicStyle(5, RGBA.randomLight, true, RGBA.randomLight));
            addCreate(handle);
            handles ~= handle;
            handle.pos = Vec2f(nextX, nextY);
            nextX *= 2;
            nextY *= 2;
            handle.isDraggable = true;
        }

        sprite = new VCircle(25, GraphicStyle(5, RGBA.randomLight, true, RGBA.randomLight));
        sprite.isDraggable = true;
        sprite.friction = 9;
        sprite.isPhysics = true;
        addCreate(sprite);
    }

    override bool draw(float at)
    {
        super.draw(at);

        import api.dm.kit.graphics.colors.rgba : RGBA;

        graphic.color = RGBA.lightcoral;

        foreach (handle; handles)
        {
            graphic.line(handle.center.x, handle.center.y, sprite.center.x, sprite.center.y);
        }

        return true;
    }

    override void update(float dt)
    {
        super.update(dt);

        Vec2f accel;
        foreach (handle; handles)
        {
            accel.x += (handle.center.x - sprite.center.x) * spring * dt;
            accel.y += (handle.center.y - sprite.center.y) * spring * dt;
        }
        sprite.acceleration = accel;
    }
}

class SpringChain : Sprite2d
{
    float spring = 2;

    override void create()
    {
        super.create;

        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
        import api.dm.kit.graphics.colors.rgba : RGBA;

        foreach (i; 0 .. 3)
        {
            auto ball = new VCircle(25, GraphicStyle(5, RGBA.randomLight, true, RGBA.randomLight));
            ball.isPhysics = true;
            ball.gravity = 3;
            ball.friction = 9;
            addCreate(ball);
        }
    }

    override bool draw(float at)
    {
        super.draw(at);

        import api.dm.kit.graphics.colors.rgba : RGBA;

        graphic.color = RGBA.lightcoral;
        graphic.line(input.pointerPos.x, input.pointerPos.y, children[0].center.x, children[0].center.y - children[0]
                .halfHeight);
        foreach (i; 1 .. children.length)
        {
            auto prev = children[i - 1];
            auto curr = children[i];
            graphic.line(prev.center.x, prev.center.y + prev.halfHeight, curr.center.x, curr.center.y - curr
                    .halfHeight);
        }

        return true;
    }

    override void update(float dt)
    {
        super.update(dt);

        apply(children[0], input.pointerPos.x, input.pointerPos.y);

        foreach (i; 1 .. children.length)
        {
            auto prev = children[i - 1];
            auto curr = children[i];

            apply(curr, prev.center.x, prev.center.y, dt);
        }
    }

    void apply(Sprite2d sprite, float targetX, float targetY, float dt)
    {
        sprite.acceleration.x = (targetX - sprite.center.x) * spring * dt;
        sprite.acceleration.y = (targetY - sprite.center.y) * spring * dt;
    }
}

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
