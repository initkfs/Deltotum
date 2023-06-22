module deltotum.phys.physical_body;

import deltotum.math.vector2d : Vector2d;
import deltotum.math.shapes.rect2d: Rect2d;
import deltotum.math.shapes.circle2d: Circle2d;
import deltotum.kit.events.event_toolkit_target: EventToolkitTarget;

/**
 * Authors: initkfs
 */
class PhysicalBody : EventToolkitTarget
{
    bool isPhysicsEnabled;
    double gravitationalAcceleration = 9.81;
    
    double restitution = 0;
    double speed = 0;

    private
    {
        double _mass = 1.0;
        double _invMass = 1.0;
    }

    this() pure @safe nothrow
    {

    }

    double invMass()
    {
        return _invMass;
    }

    double mass()
    {
        return _mass;
    }

    void mass(double value)
    {
        assert(value >= 0);

        _mass = value;
        _invMass = _mass == 0 ? 0 : 1.0 / _mass;
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
