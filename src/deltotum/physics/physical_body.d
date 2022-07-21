module deltotum.physics.physical_body;

import deltotum.math.vector2d : Vector2D;
import deltotum.math.rect: Rect;
import deltotum.events.event_target: EventTarget;

/**
 * Authors: initkfs
 */
class PhysicalBody : EventTarget
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
