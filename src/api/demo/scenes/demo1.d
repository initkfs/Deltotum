module api.demo.demo1.scenes.game;

import api.sims.phys.movings.moving;
import api.sims.phys.movings.boundaries;
import api.sims.phys.movings.physeffects;

import api.dm.gui.scenes.gui_scene : GuiScene;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.textures.vectors.shapes.vcircle : VCircle;
import api.dm.kit.sprites2d.textures.vectors.shapes.vrectangle : VRectangle;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.sims.phys.movings.moving;
import api.sims.phys.movings.physeffects;
import api.sims.phys.impulses.simple_resolver;
import api.math.geom2.circle2 : Circle2f;

import api.dm.kit.graphics.colors.rgba : RGBA;

import std.stdio;

import api.math.geom2.vec2 : Vec2f;
import Math = api.math;

/**
 * Authors: initkfs
 */
class Demo1 : GuiScene
{
    VCircle ball1;
    VCircle ball2;
    
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

        ball1 = new VCircle(50, GraphicStyle(5, RGBA.red));
        apply(ball1);
        ball1.pos = Vec2f(10, 100);
        ball1.mass = 1;
        ball2 = new VCircle(50, GraphicStyle(5, RGBA.green));
        ball2.pos = Vec2f(300, 100);
        apply(ball2);
        ball2.mass = 1;
        

        ball1.onPointerPress ~= (ref e){
            ball1.velocity = Vec2f(100);
            ball2.velocity = Vec2f(-100);
        };
    }

    void apply(Sprite2d sprite){
        sprite.isPhysics = true;
        addCreate(sprite);
    }

    override void update(float delta)
    {
        super.update(delta);

        resolve(ball1, ball2);
    }
}
