module api.demo.demo1.scenes.about;

import api.dm.gui.scenes.gui_scene : GuiScene;
import api.dm.kit.scenes.scene2d : Scene2d;

import api.dm.lib.box2d;
import std.string : toStringz, fromStringz;
import api.dm.kit.factories;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.sprites2d.textures.vectors.shapes.vshape2d : VShape;
import api.dm.kit.graphics.canvases.graphic_canvas : GStop;

import Math = api.math;

/**
 * Authors: initkfs
 */
class About : Scene2d
{
    override void create()
    {
        super.create;
    }
}
