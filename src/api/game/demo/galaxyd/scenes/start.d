module api.game.demo.galaxyd.scenes.start;

import api.dm.kit.scenes.scene : Scene;
import api.dm.gui.containers.vbox : VBox;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class Start : Scene
{
    this()
    {
        name = "start";
    }

   
    override void create()
    {
        super.create;

       
        createDebugger;
    }

    override void draw()
    {
        super.draw;
    }
}
