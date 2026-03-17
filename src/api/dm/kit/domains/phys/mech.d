module api.dm.kit.domains.phys.mech;

import api.dm.kit.domains.base_domain : BaseDomain;

import api.sims.phys.rigids2d.phys_shape : PhysShape;

/*
 * Authors: initkfs
 */

class Mech : BaseDomain
{
    PhysShape physShape;

    float angularVelocity = 0;
    float maxAngularVelocity = 0;
    float angularAcceleration = 0;
    float linearAcceleration = 0;
    float angularAngle = 0;

    float angularDamping = 0;
    float angularInertia = 0;
    float gravity = 0;
    float restitution = 0.5;

    protected
    {
        float _inertia = 0;
        float _invInertia = 0;
        float _mass = 0;
        float _invMass = 0;
    }

    bool isPhysShapeRect() => physShape == PhysShape.rect;
    bool isPhysShapeCircle() => physShape == PhysShape.circle;

    void setPhysShapeRect()
    {
        physShape = PhysShape.rect;
    }

    void setPhysShapeCircle()
    {
        physShape = PhysShape.circle;
    }

    void inertia(float newv)
    {
        _inertia = newv;
        _invInertia = (_inertia > 1e-7f) ? (1.0f / _inertia) : 0.0f;
    }

    float inertia() => _inertia;
    float invInertia() => _invInertia;

    void mass(float v)
    {
        if (v == 0)
        {
            _mass = 0;
            _invMass = 0;
            return;
        }

        _mass = v;
        _invMass = 1.0 / v;
    }

    float mass() pure @safe nothrow => _mass;
    float invMass() pure @safe nothrow => _invMass;
}
