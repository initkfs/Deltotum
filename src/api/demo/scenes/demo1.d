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
import api.sims.phys.rigids2d.collisions.joints;
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
    @Load(path: "user:Planets/planet-5.png", width: 100, height: 100)
    Image ball3;

    Sprite2d root;

    DistanceJoint joint;
    
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

        root = new Sprite2d;
        addCreate(root);
        root.isPhysics = true;
        root.physicsIters = 3;

        apply(ball1);
        ball1.pos = Vec2f(10, 150);
        ball1.isDraggable = true;
        ball1.mass = 10;
        ball1.friction = 0.8;   
        ball1.isDrawBounds = true;    
        
        apply(ball2);
        ball2.pos = Vec2f(200, 100);
        ball2.mass = 20;
        ball2.friction = 0.8;
        ball2.isDrawBounds = true;  
        ball2.isDraggable = true;

        // apply(ball3);
        // ball3.pos = Vec2f(350, 100);
        // ball3.mass = 3;
        // ball3.friction = 0.5;
        // ball3.isDrawBounds = true;  
        // ball3.isDraggable = true;

        ball1.onPointerRelease ~= (ref e){
            ball1.velocity = Vec2f(200);
            //ball3.acceleration = Vec2f(-500);
        };

        // joint = new DistanceJoint(ball1, ball2);
        // joint.length = 10;
        // joint.isPhysics = true;
        // addCreate(joint);
    }

    void apply(Sprite2d sprite){
        sprite.isPhysics = true;
        sprite.setPhysShapeCircle;
        root.addCreate(sprite);
    }

    override void update(float delta)
    {
        super.update(delta);
        
        wrapBounds(ball1, graphic.renderBounds);
        wrapBounds(ball2, graphic.renderBounds);
    }
}
