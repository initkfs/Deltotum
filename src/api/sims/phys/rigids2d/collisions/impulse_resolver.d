module api.sims.phys.rigids2d.collisions.impulse_resolver;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.math.geom2.rect2 : Rect2f;
import api.math.geom2.circle2 : Circle2f;

import api.sims.phys.rigids2d.collisions.contacts;
import api.sims.phys.rigids2d.collisions.contact_checker;

import api.math.geom2.vec2 : Vec2f;
import Math = api.math;

/**
 * Authors: initkfs
 */

bool resolve(Sprite2d a, Sprite2d b, float delta, bool isCorrectPos = true)
{
    if (!a.boundsRect.intersect(b.boundsRect))
    {
        return false;
    }

    return resolveIntersected(a, b, delta, isCorrectPos);
}

bool resolveIntersected(Sprite2d a, Sprite2d b, float delta, bool isCorrectPos = true)
{
    if (!a.boundsRect.intersect(b.boundsRect))
    {
        return false;
    }

    Contact2d collision;

    if (!checkAABBAndAABB(a.boundsRect, b.boundsRect, collision))
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
    Vec2f ra = collision.pos.sub(a.pos);
    Vec2f rb = collision.pos.sub(b.pos);

    Vec2f velLinear = b.velocity.sub(a.velocity);

    Vec2f velRotB = Vec2f.cross(b.angularVelocity, rb); // ω_b × r_b
    Vec2f velRotA = Vec2f.cross(a.angularVelocity, ra); // ω_a × r_a

    Vec2f relativeVel = velLinear.add(velRotB).sub(velRotA);

    float velAlongNormal = relativeVel.dot(collision.normal);

    if (velAlongNormal > 0)
    {
        return false;
    }

    float raCrossN = ra.cross(collision.normal); // = ra.x*normal.y - ra.y*normal.x
    float rbCrossN = rb.cross(collision.normal); // = rb.x*normal.y - rb.y*normal.x

    float invMassSum = a.invMass + b.invMass + (
        raCrossN * raCrossN) * a.invInertia + (rbCrossN * rbCrossN) * b.invInertia;

    float e = Math.min(a.restitution, b.restitution);

    float j = (-(1 + e)) * velAlongNormal;
    j /= invMassSum;

    //TODO only for acceleration\gravity or velAlongNormal < 0.1f
    //Baumgarte stabilization
    float bias = 0.0f;

    const float beta = 0.1f; //(0.1-0.3), > 0.5 cause jitter
    const float slop = 0.01f; //0.01-0.05
    const float maxBias = 2.0f;

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

    a.velocity -= impulse.scale(a.invMass);
    b.velocity += impulse.scale(b.invMass);

    a.angularVelocity -= a.invInertia * ra.cross(impulse);
    b.angularVelocity += b.invInertia * rb.cross(impulse);

    //Friction Ff <= mu * Fn
    Vec2f tangent = (relativeVel.sub(collision.normal.scale(relativeVel.dot(collision.normal))));
    if (tangent.lengthSquared > 1e-7f)
    {
        tangent = tangent.normalize;

        float raCrossT = ra.cross(tangent);
        float rbCrossT = rb.cross(tangent);
        float invMassSumTangent = a.invMass + b.invMass + (
            raCrossT * raCrossT) * a.invInertia + (rbCrossT * rbCrossT) * b.invInertia;

        if (invMassSumTangent > 1e-7f)
        {
            float jt = -relativeVel.dot(tangent);
            jt = jt / invMassSumTangent;
            //float mu = Math.pythagorean(a.friction, b.friction);
            float mu = (a.friction + b.friction) / 2;
            float maxFriction = mu * Math.abs(j);

            Vec2f frictionImpulse;
            if (Math.abs(jt) < j * mu)
                frictionImpulse = tangent.scale(jt);
            else
            {
                //dynamicFriction = Math.pythagorean(a.dynamicFriction, b.dynamicFriction);
                auto dynamicFriction = (a.dynamicFriction + b.dynamicFriction) / 2;
                frictionImpulse = tangent * (-maxFriction * dynamicFriction / mu);
            }

            a.velocity -= frictionImpulse.scale(a.invMass);
            a.angularVelocity -= a.invInertia * ra.cross(frictionImpulse);

            b.velocity += frictionImpulse.scale(b.invMass);
            b.angularVelocity += b.invInertia * rb.cross(frictionImpulse);
        }

    }

    if(isCorrectPos){
        posCorrection(a, b, collision.penetration, collision.normal);
    }

    return true;
}

void posCorrection(Sprite2d a, Sprite2d b, float penetration, Vec2f normal)
{
    const float slop = 0.01f; // 0.01 - 0.1, prevent jitter
    const float percent = 0.4f; // 20% - 80%
    const float maxCorrection = 1f;

    if (penetration <= slop)
        return;

    float correctionDepth = Math.min((penetration - slop) * percent, maxCorrection);
    Vec2f correction = normal.scale(correctionDepth);

    float totalInvMass = a.invMass + b.invMass;
    if (totalInvMass > 0)
    {
        a.pos -= correction * (a.invMass / totalInvMass);
        b.pos += correction * (b.invMass / totalInvMass);
    }
}

void applyImpulse(Sprite2d sprite, Vec2f impulse, Vec2f contactVector)
{
    //a = F/m
    sprite.velocity.add(impulse.scale(sprite.invMass));
    sprite.angularVelocity += sprite.invInertia * contactVector.cross(impulse);
}

// void calcInertia(Sprite2d sprite, Circle2f circle)
// {
//     //solid circle, or I = m * r² for rings
//     sprite.inertia = 0.5f * sprite.mass * circle.radius * circle.radius;
//     sprite.invInertia = (sprite.inertia > 1e-7f) ? 1.0f / sprite.inertia : 0.0f;
// }

// void calcInertia(Sprite2d sprite, Rect2f shape)
// {
//     //rotate around float inertia = (1.0f / 3.0f) * mass * (width*width + height*height);
//     float inertia = (1.0f / 12.0f) * mass * (width*width + height*height);
//     sprite.invInertia = (sprite.inertia > 1e-7f) ? 1.0f / sprite.inertia : 0.0f;
// }
