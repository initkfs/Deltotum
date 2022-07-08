module deltotum.physics.physical_body;

import deltotum.math.vector2d : Vector2D;
import deltotum.application.components.uni.uni_component : UniComponent;
import deltotum.math.rect: Rect;

/**
 * Authors: initkfs
 */
class PhysicalBody : UniComponent
{
    @property double mass = 0;
    @property gravitationalAcceleration = 9.81;
    @property Rect* hitbox;
    @property double restitution = 0;

    this(){
        hitbox = new Rect;
    }

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
}
