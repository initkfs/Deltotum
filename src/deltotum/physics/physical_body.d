module deltotum.physics.physical_body;

import deltotum.math.vector3d : Vector3D;
import deltotum.display.display_object : DisplayObject;

/**
 * Authors: initkfs
 */
class PhysicalBody : DisplayObject
{
    @property double mass;
    @property gravitationalAcceleration = 9.81;

    Vector3D gravity()
    {
        Vector3D gravityForce = {0, mass * -gravitationalAcceleration};
        return gravityForce;
    }

    Vector3D accelerationForce()
    {
        Vector3D gravityForce = gravity;
        Vector3D accelerationForce = {gravityForce.x / mass, gravityForce.y / mass};
        return accelerationForce;
    }

    override void update(double delta)
    {
        super.update(delta);
    }
}
