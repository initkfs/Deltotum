module deltotum.phys.physical_body;

import deltotum.math.vector2d : Vector2d;
import deltotum.math.shapes.rect2d : Rect2d;
import deltotum.math.shapes.circle2d : Circle2d;
import deltotum.kit.events.event_toolkit_target : EventToolkitTarget;

struct PhysMaterial
{
    double density = 0;
    double restitution = 0;

    static PhysMaterial rock()
    {
        return PhysMaterial(0.6, 0.1);
    }

    static PhysMaterial wood()
    {
        return PhysMaterial(0.3, 0.2);
    }

    static PhysMaterial metal()
    {
        return PhysMaterial(1.2, 0.05);
    }

    static PhysMaterial bouncyBall()
    {
        return PhysMaterial(0.3, 0.8);
    }

    static PhysMaterial superBall()
    {
        return PhysMaterial(0.3, 0.95);
    }

    static PhysMaterial pillow()
    {
        return PhysMaterial(0.1, 0.2);
    }

    static PhysMaterial statics()
    {
        return PhysMaterial(0.0, 0.4);
    }

}

/**
 * Authors: initkfs
 */
class PhysicalBody : EventToolkitTarget
{
    bool isPhysicsEnabled;

    double gravitationalAcceleration = 9.81;
    double gravityScale = 1.0;

    Vector2d gravity;

    Vector2d externalForce;

    PhysMaterial material;

    double speed = 0;

    double staticFriction = 1;
    double dynamicFriction = 1;

    Sprite isCollisionProcess;

    //TODO replace with physbody
    import deltotum.kit.sprites.sprite : Sprite;

    Sprite[] spriteForCollisions;

    void delegate(Sprite, Sprite) onCollision;

    private
    {
        //TODO multiply the density by the volume of the physical body
        double _mass = 1.0;
        double _invMass = 1.0;

        double _inertia = 0;
        double _invInertia = 0;
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

    double invInertia()
    {
        return _invInertia;
    }

    double inertia()
    {
        return _inertia;
    }

    void inertia(double value)
    {
        assert(value >= 0);

        _inertia = value;
        _invInertia = 1.0 / _inertia;
    }

    void checkCollisions()
    {
        if (!onCollision)
        {
            return;
        }
        //TODO optimizations;
        foreach (i, firstSprite; spriteForCollisions)
        {
            foreach (secondSprite; spriteForCollisions[i + 1 .. $])
            {
                if (firstSprite is secondSprite)
                {
                    continue;
                }
                if (firstSprite.intersect(secondSprite))
                {
                    if (!firstSprite.isCollisionProcess && !secondSprite.isCollisionProcess)
                    {
                        onCollision(firstSprite, secondSprite);
                    }
                }
                else
                {
                    if (firstSprite.isCollisionProcess is secondSprite)
                    {
                        firstSprite.isCollisionProcess = null;
                    }

                    if (secondSprite.isCollisionProcess is firstSprite)
                    {
                        secondSprite.isCollisionProcess = null;
                    }
                }
            }
        }
    }

    // Vector2d gravity()
    // {
    //     Vector2d gravityForce = {0, mass * -gravitationalAcceleration};
    //     return gravityForce;
    // }

    Vector2d accelerationForce()
    {
        Vector2d gravityForce = gravity;
        Vector2d accelerationForce = {gravityForce.x / mass, gravityForce.y / mass};
        return accelerationForce;
    }

    void destroy()
    {
        spriteForCollisions = null;
    }
}
