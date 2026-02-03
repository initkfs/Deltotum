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
import api.dm.kit.media.buffers.audio_buffer: AudioBuffer;
import api.sims.phys.rigids2d.fk;
import api.sims.phys.rigids2d.ik;
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

    AudioBuffer!(16384, true) audio;

    private
    {
    }

    override void create()
    {
        super.create;

        auto segment = new SegmentDrag;
        addCreate(segment);

        segment.toCenter;

        audio = new typeof(audio);
        audio.create;

        //segment.isPhysics = true;
        //segment.angularVelocity = 10;

        onPointerPress ~= (ref e){
            audio.writeTestTone(500, 5);
        };
    }

    override void dispose(){
        super.dispose;
        audio.close;
    }


    override void update(float delta)
    {
        super.update(delta);
    }
}
