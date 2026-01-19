module api.demo.demo1.scenes.game;

import api.sims.phys.rigids2d.movings.moving;
import api.sims.phys.rigids2d.movings.boundaries;
import api.sims.phys.rigids2d.movings.physeffects;

import api.dm.gui.scenes.gui_scene : GuiScene;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.textures.vectors.shapes.vcircle : VCircle;
import api.dm.kit.sprites2d.textures.vectors.shapes.vrectangle : VRectangle;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.sims.phys.rigids2d.movings.moving;
import api.sims.phys.rigids2d.movings.physeffects;
import api.sims.phys.rigids2d.collisions.impulse_resolver;
import api.dm.kit.sprites2d.images.image: Image;
import api.math.geom2.circle2 : Circle2f;
import api.dm.kit.factories.uda;

import api.dm.kit.graphics.colors.rgba : RGBA;

import std.stdio;

import api.math.geom2.vec2 : Vec2f;
import Math = api.math;

/**
 * Authors: initkfs
 */
class Demo1 : GuiScene
{
    @Load(path: "user:Planets/planet-1.png", width: 100, height: 100)
    Image ball1;
    @Load(path: "user:Planets/planet-4.png", width: 100, height: 100)
    Image ball2;
    
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

        apply(ball1);
        ball1.pos = Vec2f(10, 100);
        ball1.mass = 2;
        ball1.friction = 0.5;   
        ball1.isDrawBounds = true;    
        
        apply(ball2);
        ball2.pos = Vec2f(300, 100);
        ball2.mass = 1;
        ball2.friction = 0.5;
        ball2.isDrawBounds = true;  

        ball1.onPointerPress ~= (ref e){
            ball1.acceleration = Vec2f(100);
            ball2.acceleration = Vec2f(-100);
        };
    }

    void apply(Sprite2d sprite){
        sprite.isPhysics = true;
        addCreate(sprite);
    }

    override void update(float delta)
    {
        super.update(delta);
        

        resolve(ball1, ball2, delta);

        wrapBounds(ball1, graphic.renderBounds);
        wrapBounds(ball2, graphic.renderBounds);
    }
}
