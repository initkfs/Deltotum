module api.demo.demo1.scenes.about;

import api.dm.gui.scenes.gui_scene : GuiScene;

import api.dm.lib.box2d;
import std.string : toStringz, fromStringz;
import api.dm.kit.factories;
import api.dm.kit.sprites2d.textures.vectors.shapes.vshape2d: VShape;

/**
 * Authors: initkfs
 */
class About : GuiScene
{

    this()
    {
        name = "about";
    }

    override void create()
    {
        super.create;
    }

    override void dispose()
    {
        super.dispose;

    }
}
