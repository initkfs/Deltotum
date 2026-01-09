module api.demo.demo1.scenes.game;

import api.sims.phys.movings.moving;
import api.sims.phys.movings.boundaries;

import api.dm.gui.scenes.gui_scene : GuiScene;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.textures.vectors.shapes.vcircle : VCircle;
import api.dm.kit.graphics.colors.rgba: RGBA;

import std.stdio;

import Math = api.math;

class Spring4 : Sprite2d
{
    VCircle ball;
    RandomAngleMotion move;

    override void create(){

        move = new RandomAngleMotion;
        
        super.create;
        import api.dm.kit.graphics.styles.graphic_style: GraphicStyle;
        import api.dm.kit.graphics.colors.rgba: RGBA;
		ball = new VCircle(25, GraphicStyle(5, RGBA.cyan, true, RGBA.lightcyan));
		addCreate(ball);
        ball.isPhysics = true;

        // move.sprite = ball;
        ball.pos(200, 200);
        ball.isDraggable = true;

        ball.onPointerPress ~= (ref e){
            ball.gravity = 50;
        };
    }

    override bool draw(float alpha){
        super.draw(alpha);

        graphic.color = RGBA.greenyellow;
        graphic.rect(graphic.renderBounds);
        graphic.rect(ball.boundsRect);
        return true;
    }

    override void update(float dt){
        super.update(dt);

        auto bounds = graphic.renderBounds;
        bounds.y -= 100;
        throwing(ball, bounds);
        //move.update(dt);
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
