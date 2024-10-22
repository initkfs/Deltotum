module api.demo.demo1.scenes.start;

import api.dm.kit.scenes.scene : Scene;
import api.dm.gui.containers.vbox : VBox;
import api.dm.gui.containers.hbox : HBox;
import api.dm.gui.controls.buttons.button : Button;
import api.dm.kit.sprites.textures.texture: Texture;
import api.dm.kit.sprites.images.image: Image;

import Math = api.dm.math;
import api.math.random : Random;

import api.dm.kit.factories;

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

    @placeholder(50, 50, true) Texture item1;

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
