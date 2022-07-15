module demo.cybercity.world.vehicles.police;

import deltotum.display.bitmap.bitmap : Bitmap;
import deltotum.animation.object.value_transition : ValueTransition;
import deltotum.animation.object.property.opacity_transition : OpacityTransition;
import deltotum.math.direction: Direction;
import demo.cybercity.world.vehicles.vehicle: Vehicle;

//TODO remove HAL layer
import bindbc.sdl;

import std.stdio : writeln;

/**
 * Authors: initkfs
 */
class Police : Vehicle
{
    @property speed = 200;

    private
    {
        OpacityTransition flasherTransition;
        Bitmap flasher;
    }

    override void create()
    {
        super.create;
        direction = Direction.left;

        load("cybercity/town/vehicles/v-police.png");
        x = window.getWidth;
        //x = 100;
        y = 80;

        flasher = new Bitmap;
        build(flasher);
        flasher.load("cybercity/town/vehicles/flasher_red.png");
        flasher.x = 100;
        flasher.y = -10;
        add(flasher);

        flasherTransition = new OpacityTransition(flasher, 500);
        build(flasherTransition);
        flasherTransition.run;
        add(flasherTransition);
    }

    override void update(double delta)
    {
        super.update(delta);
    }
}
