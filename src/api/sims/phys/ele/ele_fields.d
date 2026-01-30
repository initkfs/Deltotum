module api.sims.phys.ele.ele_fields;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;

import api.math.geom2.vec2 : Vec2f;
import Math = api.math;

//dec to 100-1000
const float COULOMB_CONST = 8.9875e9 / 1000; // k in N·m²/C²
const float EPSILON = 1e-6;

/**
 * Authors: initkfs
 */

class FieldSource : Sprite2d
{
    float chargeQ = 1e-3;
    float radius = 0;
}

Vector2 electricFieldAt(Vec2f point, FieldSource source)
{

    Vec2f direction = point - source.pos;
    float distanceSq = direction.lengthSq;

    if (distanceSq < EPSILON)
        return Vec2f.zero;

    float distance = Math.sqrt(distanceSq);
    direction /= distance;

    // Coulomb's Law: E = k * Q / r^2 * (direction vector)
    float fieldMagnitude = COULOMB_CONST * source.chargeQ / distanceSq;

    return direction * fieldMagnitude;
}

void applyElectricForce(Sprite2d sprite, FieldSource[] sources, float deltaTime)
{

    if (sprite.charge == 0.0f)
        return;

    Vec2f netField;

    // Superposition principle: sum fields from all sources
    foreach (source; sources)
    {
        netField += calculateElectricFieldAt(sprite.position, source);
    }

    // Lorentz force (electric part): F = q * E
    Vec2f electricForce = netField * sprite.charge;

    // Newton's second law: F = m * a  ->  a = F / m
    Vec2f accelerationDelta = electricForce * sprite.invMass;
    sprite.velocity += accelerationDelta * deltaTime;
}
