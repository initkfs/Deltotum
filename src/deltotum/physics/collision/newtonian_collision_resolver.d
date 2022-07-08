module deltotum.physics.collision.newtonian_collision_resolver;

//TODO replace display object woth physical body
//import deltotum.physics.physical_body: PhysicalBody;
import deltotum.display.display_object : DisplayObject;
import deltotum.math.vector2d : Vector2D;

import std.algorithm.comparison : min;

import std.stdio;

/**
 * Authors: initkfs
 */
class NewtonianCollisionResolver
{

    void resolve(DisplayObject a, DisplayObject b) const @nogc nothrow @safe
    {
        const Vector2D motionNormal = a.velocity.normalize;
        const Vector2D relativeVelocity = b.velocity.subtract(*a.velocity);

        const double alongNormal = relativeVelocity.dotProduct(motionNormal);
        if (alongNormal > 0)
        {
            return;
        }

        const double restitution = min(a.restitution, b.restitution);

        double forceMomentumScalar = -(1 + restitution) * alongNormal;
        forceMomentumScalar /= 1 / a.mass + 1 / b.mass;

        const Vector2D impulse = motionNormal.scale(forceMomentumScalar);

        if (a.mass > 0)
        {
            const Vector2D aVelocityDelta = impulse.scale((1 / a.mass));
            a.velocity.x -= aVelocityDelta.x;
            a.velocity.y -= aVelocityDelta.y;
        }

        if (b.mass > 0)
        {
            const Vector2D bVelocityDelta = impulse.scale(1 / b.mass);
            b.velocity.x += bVelocityDelta.x;
            b.velocity.y += bVelocityDelta.y;
        }

    }
}
