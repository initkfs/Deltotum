module api.demo.demo1.scenes.game;

import api.dm.gui.scenes.gui_scene : GuiScene;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.textures.vectors.shapes.vcircle : VCircle;
import api.dm.kit.sprites2d.textures.vectors.shapes.vrectangle : VRectangle;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.factories.uda;

import api.dm.kit.graphics.colors.rgba : RGBA;

import api.math.geom2.vec2 : Vec2f;
import std.string : toStringz, fromStringz;
import Math = api.math;

import std;

/**
 * Authors: initkfs
 */
class Demo1 : GuiScene
{

    this()
    {
        name = "game";
    }

    bool isRun;

    override void create()
    {
        super.create;
    }

    override void dispose()
    {
        super.dispose;
    }

    override void update(float delta)
    {
        super.update(delta);
    }
}
