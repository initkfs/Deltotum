module deltotum.physics.physical_body;

import deltotum.math.vector2d : Vector2d;
import deltotum.math.shapes.rect2d: Rect2d;
import deltotum.events.event_target: EventTarget;

/**
 * Authors: initkfs
 */
class PhysicalBody : EventTarget
{
    @property double mass = 0;
    @property gravitationalAcceleration = 9.81;
    @property Rect2d* hitbox;
    @property double restitution = 0;

    this(){
        hitbox = new Rect2d;
    }

    Vector2d gravity()
    {
        Vector2d gravityForce = {0, mass * -gravitationalAcceleration};
        return gravityForce;
    }

    Vector2d accelerationForce()
    {
        Vector2d gravityForce = gravity;
        Vector2d accelerationForce = {gravityForce.x / mass, gravityForce.y / mass};
        return accelerationForce;
    }
}
