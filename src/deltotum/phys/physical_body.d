module deltotum.phys.physical_body;

import deltotum.math.vector2d : Vector2d;
import deltotum.math.shapes.rect2d: Rect2d;
import deltotum.kit.events.event_toolkit_target: EventToolkitTarget;

/**
 * Authors: initkfs
 */
class PhysicalBody : EventToolkitTarget
{
    double mass = 0;
    double gravitationalAcceleration = 9.81;
    Rect2d* hitbox;
    double restitution = 0;
    double speed = 0;

    this() pure @safe {
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
