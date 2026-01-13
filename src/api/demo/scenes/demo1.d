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

import api.dm.kit.graphics.colors.rgba : RGBA;

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

        addCreate(new AngleBounce);
    }

    override void update(float delta)
    {
        super.update(delta);
    }
}
