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

        import api.dm.kit.genart.hopalongs.hopalong_generator: HopalongGenerator;

        auto gen = new HopalongGenerator;
        gen.width = 400;
        gen.height = 400;
        addCreate(gen);
        gen.moveToCenter;

       
        createDebugger;
    }

    override void draw()
    {
        super.draw;
    }
}
