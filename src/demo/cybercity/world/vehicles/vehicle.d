module demo.cybercity.world.vehicles.vehicle;

import deltotum.display.bitmap.bitmap : Bitmap;
import deltotum.math.direction : Direction;
import deltotum.animation.object.value_transition : ValueTransition;

//TODO remove HAL layer
import bindbc.sdl;

import std.stdio : writeln;

/**
 * Authors: initkfs
 */
class Vehicle : Bitmap
{
    @property speed = 200;
    @property direction = Direction.none;

    private
    {
        ValueTransition yTransition;
    }

    override void create()
    {
        yTransition = new ValueTransition(this, 65, 95, 2000);
        build(yTransition);
        yTransition.onValue = (y) { this.y = y; };
        add(yTransition);
        yTransition.run;
    }

    override void update(double delta)
    {
        super.update(delta);

        if (direction == Direction.left && bounds.right < 0)
        {
            x = window.getWidth;
        }
        else if (direction == Direction.right && x > window.getWidth)
        {
            x = -width;
        }

        if (direction == Direction.left)
        {
            x = x - (delta * speed);
        }
        else if (direction == Direction.right)
        {
            x = x + (delta * speed);
        }
    }
}
