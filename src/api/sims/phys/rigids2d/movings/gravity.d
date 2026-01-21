module api.sims.phys.rigids2d.movings.gravity;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;

import Math = api.math;

/**
 * Authors: initkfs
 */

void gravitate(Sprite2d a, Sprite2d b, float deltaTime, float g = 1000, float maxDistanceSqr = 100000, float minDist = 1,  float softening = 1.0)
{
    auto direction = b.center - a.center;

    auto distSQ = Math.max(direction.lengthSquared() + softening * softening, minDist * minDist);

    if (distSQ > maxDistanceSqr){
        return;
    }

    auto invDist = 1.0f / Math.sqrt(distSQ);
    auto dirNorm = direction * invDist;

    auto force = g * (a.mass * b.mass / distSQ);

    //  F / m_a
    auto acceleration = dirNorm * (force / a.mass) * deltaTime;

    a.velocity += acceleration;
    b.velocity -= acceleration * (a.mass / b.mass);
}
