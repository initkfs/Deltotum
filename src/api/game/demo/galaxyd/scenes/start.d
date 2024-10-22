module api.game.demo.galaxyd.scenes.start;

import api.dm.kit.scenes.scene : Scene;
import api.dm.gui.containers.vbox : VBox;
import api.dm.gui.containers.hbox : HBox;
import api.dm.gui.controls.buttons.button : Button;

import Math = api.dm.math;
import api.math.random : Random;

/**
 * Authors: initkfs
 */
class Start : Scene
{
    this()
    {
        name = "start";
    }

    import api.math;
    import api.dm.kit.graphics.colors.rgba : RGBA;

    Random rnd;

    override void create()
    {
        super.create;

        rnd = new Random;

       
        createDebugger;
    }

    override void draw()
    {
        super.draw;
    }
}
