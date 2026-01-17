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

bool resolve(Sprite2d a, Sprite2d b)
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

    if (!resolve(a, b, collision))
    {
        return false;
    }

    return true;
}

bool resolve(Sprite2d a, Sprite2d b, Contact2d collision)
{
    Vec2f relativeVel = b.velocity - a.velocity;

    float velAlongNormal = relativeVel.dot(collision.normal);

    if (velAlongNormal > 0)
    {
        return false;
    }

    float e = Math.min(a.restitution, b.restitution);

    float j = (-(1 + e)) * velAlongNormal;
    j /= a.invMass + b.invMass;

    Vec2f impulse = collision.normal.scale(j);

    a.velocity -= impulse.scale(a.invMass);
    b.velocity += impulse.scale(b.invMass);

    posCorrection(a, b, collision.penetration, collision.normal);

    return true;
}

void posCorrection(Sprite2d a, Sprite2d b, float penetration, Vec2f normal)
{
    const float slop = 0.01f; // 0.01 - 0.1, prevent jitter
    const float percent = 0.8f; // 20% - 80%

    if (penetration <= slop)
        return;

    float correctionDepth = (penetration - slop) * percent;
    Vec2f correction = normal.scale(correctionDepth);

    float totalInvMass = a.invMass + b.invMass;
    if (totalInvMass > 0)
    {
        a.pos -= correction * (a.invMass / totalInvMass);
        b.pos += correction * (b.invMass / totalInvMass);
    }
}
