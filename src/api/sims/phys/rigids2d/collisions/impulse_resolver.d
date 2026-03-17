module api.sims.phys.rigids2d.collisions.impulse_resolver;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.math.geom2.rect2 : Rect2f;
import api.math.geom2.circle2 : Circle2f;

import api.sims.phys.rigids2d.collisions.contacts;
import api.sims.phys.rigids2d.collisions.contact_checker;
import api.sims.phys.rigids2d.phys_shape : calcInertia;

import api.math.geom2.vec2 : Vec2f;
import Math = api.math;

/**
 * Authors: initkfs
 */

bool resolve(Sprite2d a, Sprite2d b, float delta, bool isCorrectPos = true)
{
    Contact2d collision;

    auto physBodyA = a.domains.mech;
    auto physBodyB = b.domains.mech;

    if (physBodyA.isPhysShapeRect && physBodyB.isPhysShapeRect)
    {
        if (!a.boundsRect.intersect(b.boundsRect))
        {
            return false;
        }

        if (!checkAABBAndAABB(a.boundsRect, b.boundsRect, collision))
        {
            return false;
        }
    }
    else if (physBodyA.isPhysShapeCircle && physBodyB.isPhysShapeCircle)
    {
        if (!a.boundsCircle.intersect(b.boundsCircle))
        {
            return false;
        }

        if (!checkCircleAndCircle(a.boundsCircle, b.boundsCircle, collision))
        {
            return false;
        }
    }
    else
    {
        return false;
    }

    if (!resolve(a, b, collision, delta, isCorrectPos))
    {
        return false;
    }

    return true;
}

bool resolve(Sprite2d a, Sprite2d b, Contact2d collision, float dt, bool isCorrectPos = true)
{
    auto physBodyA = a.domains.mech;
    auto physBodyB = a.domains.mech;

    Vec2f ra = collision.pos.sub(a.center);
    Vec2f rb = collision.pos.sub(b.center);

    Vec2f velLinear = b.velocity.sub(a.velocity);

    Vec2f velRotB = Vec2f.cross(rb, physBodyB.angularVelocity); // ω_b × r_b
    Vec2f velRotA = Vec2f.cross(ra, physBodyA.angularVelocity); // ω_a × r_a

    Vec2f relativeVel = velLinear.add(velRotB).sub(velRotA);

    float velAlongNormal = relativeVel.dot(collision.normal);

    if (velAlongNormal > 0)
    {
        return false;
    }

    float raCrossN = ra.cross(collision.normal); // = ra.x*normal.y - ra.y*normal.x
    float rbCrossN = rb.cross(collision.normal); // = rb.x*normal.y - rb.y*normal.x

    // calcInertia(a);
    // calcInertia(b);

    float invMassSum = physBodyA.invMass + physBodyB.invMass + (
        raCrossN * raCrossN) * physBodyA.invInertia + (rbCrossN * rbCrossN) * physBodyB.invInertia;

    //float e = Math.min(a.restitution, b.restitution);
    float e = (physBodyA.restitution + physBodyB.restitution) / 2;

    float j = (-(1 + e)) * velAlongNormal;
    j /= invMassSum;

    //TODO only for acceleration\gravity or velAlongNormal < 0.1f
    //Baumgarte stabilization
    float bias = 0.0f;

    const float beta = 0.1f; //(0.1-0.3), > 0.5 cause jitter
    const float slop = 0.01f; //0.01-0.05
    const float maxBias = 50;

    if (collision.penetration > slop)
    {
        if (dt < 1e-7f)
        {
            bias = 0.0f;
        }
        else
        {
            bias = (beta / dt) * (collision.penetration - slop);
            bias = Math.min(bias, maxBias);
        }

    }

    j += bias;

    Vec2f impulse = collision.normal.scale(j);

    a.velocity -= impulse.scale(physBodyA.invMass);
    b.velocity += impulse.scale(physBodyB.invMass);

    //a.angularVelocity -= a.invInertia * ra.cross(impulse);
    //b.angularVelocity += b.invInertia * rb.cross(impulse);

    //Friction Ff <= mu * Fn
    Vec2f tangent = (relativeVel.sub(collision.normal.scale(relativeVel.dot(collision.normal))));

    if (tangent.lengthSquared > 1e-7f)
    {
        tangent = tangent.normalize;

        float raCrossT = ra.cross(tangent);
        float rbCrossT = rb.cross(tangent);

        float invMassSumTangent = physBodyA.invMass + physBodyB.invMass + (
            raCrossT * raCrossT) * physBodyA.invInertia + (rbCrossT * rbCrossT) * physBodyB
            .invInertia;

        if (invMassSumTangent > 1e-7f)
        {
            float jt = -relativeVel.dot(tangent);
            jt = jt / invMassSumTangent;
            //float mu = Math.pythagorean(a.friction, b.friction);
            float mu = (a.damping + b.damping) / 2;
            float maxFriction = mu * Math.abs(j);

            Vec2f frictionImpulse;

            if (Math.abs(jt) < maxFriction)
                frictionImpulse = tangent.scale(jt);
            else
            {
                //dynamicFriction = Math.pythagorean(a.dynamicFriction, b.dynamicFriction);
                //auto dynamicFriction = (a.dynamicFriction + b.dynamicFriction) / 2;
                //frictionImpulse = tangent * (-maxFriction * dynamicFriction / mu);
                frictionImpulse = tangent.scale(-maxFriction * Math.sign(jt));
            }

            a.velocity -= frictionImpulse.scale(physBodyA.invMass);

            const angInvInertiaA = physBodyA.angularInertia != 0 ? 1.0 / physBodyB.angularInertia
                : physBodyA.invInertia;
            physBodyA.angularVelocity -= angInvInertiaA * ra.cross(frictionImpulse);

            b.velocity += frictionImpulse.scale(physBodyB.invMass);

            const angInvInertiaB = physBodyB.angularInertia != 0 ? 1.0 / physBodyB.angularInertia
                : physBodyB.invInertia;
            physBodyB.angularVelocity += angInvInertiaB * rb.cross(frictionImpulse);
        }

    }

    if (isCorrectPos)
    {
        posCorrection(a, b, collision.penetration, collision.normal);
    }

    return true;
}

void posCorrection(Sprite2d a, Sprite2d b, float penetration, Vec2f normal)
{
    auto physBodyA = a.domains.mech;
    auto physBodyB = a.domains.mech;

    const float slop = 0.01f; // 0.01 - 0.1, prevent jitter
    const float percent = 0.4f; // 20% - 80%
    const float maxCorrection = 1f;

    if (penetration <= slop)
        return;

    float correctionDepth = Math.min((penetration - slop) * percent, maxCorrection);
    Vec2f correction = normal.scale(correctionDepth);

    float totalInvMass = physBodyA.invMass + physBodyB.invMass;
    if (totalInvMass > 0)
    {
        a.pos -= correction * (physBodyA.invMass / totalInvMass);
        b.pos += correction * (physBodyB.invMass / totalInvMass);
    }
}

void applyImpulse(Sprite2d sprite, Vec2f impulse, Vec2f contactVector)
{
    //a = F/m
    sprite.velocity.add(impulse.scale(sprite.domains.mech.invMass));
    sprite.domains.mech.angularVelocity += sprite.domains.mech.invInertia * contactVector.cross(
        impulse);
}
