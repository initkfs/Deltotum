module api.demo.demo1.scenes.start;

import api.dm.kit.scenes.scene : Scene;
import api.dm.gui.containers.vbox : VBox;
import api.dm.gui.containers.hbox : HBox;
import api.dm.gui.controls.buttons.button : Button;
import api.dm.kit.sprites.textures.texture : Texture;
import api.dm.kit.sprites.images.image : Image;

import Math = api.dm.math;
import api.math.random : Random;
import api.math.geom2.vec2 : Vec2d;

import api.dm.kit.factories;

import std : writeln;

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

        //auto eps = epsilon;

        // auto intersection = intersect(
        //     eps,
        //     polygon(
        //         region(
        //         point(50, 50),
        //         point(150, 150),
        //         point(190, 50)
        //     ),
        //     region(
        //         point(130, 50),
        //         point(290, 150),
        //         point(290, 50)
        // )
        // ),
        // polygon(
        //     region(
        //         point(110, 20),
        //         point(110, 110),
        //         point(20, 20)
        // ),
        // region(
        //     point(130, 170),
        //     point(130, 20),
        //     point(260, 20),
        //     point(260, 170)
        // )
        // )
        // );

        // import std;
        // writeln(intersection.regions);

        createDebugger;
    }

    override void update(double dt)
    {
        super.update(dt);
    }

    override void draw()
    {
        super.draw;
    }
}
