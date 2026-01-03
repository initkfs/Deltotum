module api.demo.demo1.scenes.game;

import api.dm.gui.scenes.gui_scene : GuiScene;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.textures.vectors.shapes.vcircle : VCircle;

import std.stdio;

import Math = api.math;

class Spring4 : Sprite2d
{
    VCircle ball;
    float spring = 2.5;
    float targetX = 0;
    float targetY = 0;
    float vx = 0;
    float vy = 0;
    float friction = 0.95;

    override void create(){
        super.create;
        targetX = window.halfWidth;
		targetY = window.halfHeight;

        import api.dm.kit.graphics.styles.graphic_style: GraphicStyle;
        import api.dm.kit.graphics.colors.rgba: RGBA;
		ball = new VCircle(50, GraphicStyle(10, RGBA.cyan, true, RGBA.lightcyan));
		addCreate(ball);
    }

    override void update(float dt){
        super.update(dt);

        const pointerPos = input.pointerPos;
        auto dx = pointerPos.x - ball.center.x;
		auto dy  = pointerPos.y - ball.center.y;

		vx += dx * spring * dt;
		vy += dy * spring * dt;

		vx *= friction;
		vy *= friction;

		ball.x = ball.x + vx;
		ball.y = ball.y + vy;
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
