module api.demo.demo1.scenes.game;

import api.sims.phys.movings.moving;
import api.sims.phys.movings.boundaries;
import api.sims.phys.movings.physeffects;

import api.dm.gui.scenes.gui_scene : GuiScene;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.textures.vectors.shapes.vcircle : VCircle;
import api.dm.kit.graphics.colors.rgba : RGBA;

import std.stdio;

import api.math.geom2.vec2 : Vec2f;
import Math = api.math;

class Spring4 : Sprite2d
{
    VCircle ball;
    RandomAngleMotion move;

    OffsetSpring moving;

    override void create()
    {

        moving = new OffsetSpring;

        super.create;
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
        import api.dm.kit.graphics.colors.rgba : RGBA;

        //addCreate(moving);

        //moving.spring = 0.1;

        ball = new VCircle(20);
        ball.isPhysics = true;
        addCreate(ball);
        ball.toCenter;
        ball.onPointerPress ~= (ref e){
            ball.gravity = 10;
        };
    }

    override bool draw(float alpha)
    {
        super.draw(alpha);

        graphic.color = RGBA.greenyellow;
        graphic.rect(graphic.renderBounds);
        //graphic.rect(ball.boundsRect);
        return true;
    }

    override void update(float dt)
    {
        super.update(dt);

        auto bounds = graphic.renderBounds;
        bounds.y -= 100;
        //throwing(ball, bounds);
    }
}

/**
 * Authors: initkfs
 */
class Demo1 : GuiScene
{
    this()
    {
        name = "game";
    }

    private
    {
    }

    override void create()
    {
        super.create;
        addCreate(new Spring4);
    }

    override void update(float delta)
    {
        super.update(delta);
    }
}
