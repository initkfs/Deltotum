module api.sims.phys.ele.ele_fields;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites3d.sprite3d : Sprite3d;

import api.math.geom2.vec2 : Vec2f;
import api.math.geom3.vec3 : Vec3f;
import Math = api.math;

//dec to 100-1000
const float COULOMB_CONST = 8.9875e9 / 1000; // k in N·m²/C²
const float EPSILON = 1e-6;

/**
 * Authors: initkfs
 */

class FieldSource : Sprite3d
{
    float chargeQ = 1e-3;
    float radius = 0;

    //0 if not a magnetic source
    float currentI = 0;

    //normalized
    Vec3f direction;
    float length = 0;
}

Vec2f electricFieldAt(Vec2f point, FieldSource source)
{
    Vec2f direction = point - source.pos;
    float distanceSq = direction.lengthSquared;

    if (distanceSq < EPSILON)
        return Vec2f.zero;

    float distance = Math.sqrt(distanceSq);
    direction = direction.div(distance);

    // Coulomb's Law: E = k * Q / r^2 * (direction vector)
    float fieldMagnitude = COULOMB_CONST * source.chargeQ / distanceSq;

    return direction * fieldMagnitude;
}

Vec2f magneticFieldAt(Vec2f point, FieldSource source)
{
    // Magnetic field from a wire along Z-axis at source.pos
    // B = (μ₀ * I) / (2π * r) * (tangent direction)
    const float MU0_OVER_2PI = 2e-7; // (μ₀ / 2π) constant

    Vec2f rVec = point - source.pos;
    float distance = rVec.length;

    if (distance < EPSILON)
        return Vec2f.zero;

    // For wire along Z
    // In 2D treat B as a pseudo-vector: rotate rVec by 90 degrees (counter-clockwise)
    Vec2f bDirection = Vec2f(-rVec.y, rVec.x).normalize;

    float bMagnitude = MU0_OVER_2PI * source.currentI / distance;
    return bDirection * bMagnitude;
}

Vec3f magneticFieldAt3(Vec3f point, FieldSource source)
{
    if (source.currentI == 0.0f)
    {
        return Vec3f.zero;
    }

    const float MU0_OVER_4PI = 1e-7; // μ₀/(4π) = 1e-7 N/A² exactly

    Vec3f start = source.pos3;
    Vec3f end = start + source.direction * source.length;

    Vec3f r1 = point - start;
    Vec3f r2 = point - end;

    float r1_len = r1.length;
    float r2_len = r2.length;

    if (r1_len < EPSILON || r2_len < EPSILON)
    {
        return Vec3f.zero;
    }

    // dl × r̂
    Vec3f directionUnit = source.direction.normalize;

    Vec3f r1_unit = r1 / r1_len;
    Vec3f r2_unit = r2 / r2_len;

    // Biot-Savart law:
    // B = (μ₀ I / 4π) * (dl × r) / r²
    Vec3f crossProd = directionUnit.cross(r1_unit); // dl × r̂

    // Geometric factor: (cosθ₁ - cosθ₂)
    float cosTheta1 = directionUnit.dot(r1_unit);
    float cosTheta2 = directionUnit.dot(r2_unit);
    float factor = (cosTheta1 - cosTheta2) / r1_len;

    Vec3f B = crossProd * (MU0_OVER_4PI * source.currentI * factor);

    return B;
}

Vec3f dipoleFieldAt(Vec3f point, Vec3f dipoleMoment, Vec3f dipolePosition)
{
    const float MU0_OVER_4PI = 1e-7;

    Vec3f r = point - dipolePosition;
    float r_len = r.length;

    if (r_len < EPSILON)
        return Vec3f.zero;

    Vec3f r_unit = r / r_len;
    float r3 = r_len * r_len * r_len;

    // Dipole field: B = (μ₀/4π) * [3(m·r̂)r̂ - m] / r³
    float m_dot_r = dipoleMoment.dot(r_unit);

    Vec3f term1 = r_unit * (3.0f * m_dot_r);
    Vec3f term2 = dipoleMoment;

    Vec3f B = (term1 - term2) * (MU0_OVER_4PI / r3);

    return B;
}

void applyElectricForce(Sprite2d sprite, FieldSource[] sources, float deltaTime)
{
    if (sprite.charge == 0.0f)
        return;

    Vec2f netField;

    // Superposition: sum fields from all sources
    foreach (source; sources)
    {
        netField += electricFieldAt(sprite.pos, source);
    }

    // Lorentz force F = q * E
    Vec2f electricForce = netField * sprite.charge;

    //F = m * a  ->  a = F / m
    Vec2f accelerationDelta = electricForce * sprite.invMass;
    sprite.velocity += accelerationDelta * deltaTime;
}

void applyElectromagneticForce(Sprite2d sprite, FieldSource[] sources, float deltaTime)
{

    if (sprite.charge == 0.0f)
        return;

    Vec2f netElectricField;
    Vec2f netMagneticField;

    // Superposition: sum all fields from sources
    foreach (source; sources)
    {
        netElectricField += electricFieldAt(sprite.pos, source);
        if (source.currentI != 0.0f)
        {
            netMagneticField += magneticFieldAt(sprite.pos, source);
        }
    }

    // Electric force: F_e = q * E
    Vec2f electricForce = netElectricField * sprite.charge;

    // Magnetic force: F_m = q * [v × B]
    // In 2D: v is in XY, B is out-of-plane (scalar).
    // Then F_m magnitude = q * v * B, direction perpendicular to velocity.
    float bMagnitude = netMagneticField.length;
    Vec2f magneticForce;
    if (bMagnitude > 0 && sprite.velocity.lengthSquared > 0)
    {
        // Force direction: perpendicular to velocity (rotate 90 degrees)
        Vec2f perpDir = Vec2f(-sprite.velocity.y, sprite.velocity.x).normalize;
        magneticForce = perpDir * (sprite.charge * sprite.velocity.length * bMagnitude);
    }

    // Total Lorentz force
    Vec2f totalForce = electricForce + magneticForce;

    Vec2f accelerationDelta = totalForce * sprite.invMass;
    sprite.velocity += accelerationDelta * deltaTime;
}
