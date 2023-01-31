module deltotum.engine.physics.physical_body;

import deltotum.core.math.vector2d : Vector2d;
import deltotum.core.math.shapes.rect2d: Rect2d;
import deltotum.engine.events.event_target: EventTarget;

/**
 * Authors: initkfs
 */
class PhysicalBody : EventTarget
{
    double mass = 0;
    double gravitationalAcceleration = 9.81;
    Rect2d* hitbox;
    double restitution = 0;
    double speed = 0;

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
