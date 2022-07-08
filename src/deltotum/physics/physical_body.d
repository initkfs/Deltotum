module deltotum.physics.physical_body;

import deltotum.math.vector2d : Vector2D;
import deltotum.display.display_object : DisplayObject;

/**
 * Authors: initkfs
 */
class PhysicalBody : DisplayObject
{
    @property double mass;
    @property gravitationalAcceleration = 9.81;

    Vector2D gravity()
    {
        Vector2D gravityForce = {0, mass * -gravitationalAcceleration};
        return gravityForce;
    }

    Vector2D accelerationForce()
    {
        Vector2D gravityForce = gravity;
        Vector2D accelerationForce = {gravityForce.x / mass, gravityForce.y / mass};
        return accelerationForce;
    }

    override void update(double delta)
    {
        super.update(delta);
    }
}
