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
import api.dm.kit.sprites2d.images.image : Image;
import api.math.geom2.circle2 : Circle2f;
import api.dm.kit.factories.uda;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.sims.phys.rigids2d.movings.gravity;
import api.sims.phys.rigids2d.fk;
import std.stdio;

import api.math.geom2.vec2 : Vec2f;
import Math = api.math;

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

        auto segment = new SegmentWalk;
        addCreate(segment);

        segment.toCenter;

        //segment.isPhysics = true;
        //segment.angularVelocity = 10;
    }


    override void update(float delta)
    {
        super.update(delta);
    }
}
