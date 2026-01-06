module api.demo.demo1.scenes.game;

import api.sims.phys.movings.moving;

import api.dm.gui.scenes.gui_scene : GuiScene;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.textures.vectors.shapes.vcircle : VCircle;

import std.stdio;

import Math = api.math;

class Spring4 : Sprite2d
{
    VCircle ball;
    SpringToSprite springTo;

    override void create(){

        springTo = new SpringToSprite;
        
        super.create;
        import api.dm.kit.graphics.styles.graphic_style: GraphicStyle;
        import api.dm.kit.graphics.colors.rgba: RGBA;
		ball = new VCircle(50, GraphicStyle(10, RGBA.cyan, true, RGBA.lightcyan));
		addCreate(ball);

        springTo.sprite = ball;
    }

    override void update(float dt){
        super.update(dt);

        springTo.toPoint = input.pointerPos;
        springTo.update(dt);
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
