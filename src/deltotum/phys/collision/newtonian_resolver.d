module deltotum.phys.collision.newtonian_resolver;

//TODO replace display object woth physical body
//import deltotum.phys.physical_body: PhysicalBody;
import deltotum.kit.sprites.sprite : Sprite;
import deltotum.math.vector2d : Vector2d;
import deltotum.math.shapes.circle2d : Circle2d;
import deltotum.math.shapes.rect2d : Rect2d;
import deltotum.kit.graphics.shapes.rectangle : Rectangle;
import deltotum.kit.graphics.shapes.circle : Circle;

import Math = deltotum.math;

import std.stdio;

struct CollisionResult
{
    double penetration = 0;
    Vector2d normal;
}

/**
 * Authors: initkfs
 */
class NewtonianResolver
{
    double maxImpulseValue = 500;

    void resolve(Sprite a, Sprite b)
    {
        const massSum = a.mass + b.mass;
        if (massSum == 0)
        {
            return;
        }

        CollisionResult collisionData;

        auto aHitbox = a.hitbox;
        auto bHitbox = b.hitbox;

        if (!aHitbox || !bHitbox)
        {
            return;
        }

        //TODO remove casts
        if (auto aRect = cast(Rectangle) a.hitbox)
        {
            if (auto bRect = cast(Rectangle) b.hitbox)
            {
                collisionAABB(aRect, bRect, collisionData);
            }

            if (auto bCircle = cast(Circle) b.hitbox)
            {
                collisionAABBvsCircle(aRect, bCircle, collisionData);
            }
        }

        if (auto aCircle = cast(Circle) a.hitbox)
        {
            if (auto bCircle = cast(Circle) b.hitbox)
            {
                collisionCircles(aCircle, bCircle, collisionData);
            }

            if (auto bRect = cast(Rectangle) b.hitbox)
            {
                collisionAABBvsCircle(bRect, aCircle, collisionData);
            }
        }

        const Vector2d relativeVelocity = b.velocity - a.velocity;
        const Vector2d collisionNormal = collisionData.normal;

        const double alongNormal = relativeVelocity.dotProduct(collisionNormal);
        if (alongNormal > 0)
        {
            return;
        }

        const double restitution = Math.min(a.material.restitution, b.material.restitution);

        double forceMomentumScalar = -(1 + restitution) * alongNormal;
        forceMomentumScalar /= a.invMass + b.invMass;

        const Vector2d impulse = collisionNormal.scale(forceMomentumScalar);

        const massRatioA = 1.0 - a.mass / massSum;
        const massRatioB = 1.0 - b.mass / massSum;

        const Vector2d maxValue = Vector2d(maxImpulseValue, maxImpulseValue);

        const Vector2d aVelDelta = impulse.scale(massRatioA).min(maxValue);
        const Vector2d bVelDelta = impulse.scale(massRatioB).min(maxValue);

        a.isCollisionProcess = b;
        b.isCollisionProcess = a;

        a.velocity -= aVelDelta;
        b.velocity += bVelDelta;

        const double penetration = collisionData.penetration;

        if (penetration > 0)
        {
            const double percent = 0.3; // 0.2 - 0.8
            const double slop = 0.5; //0.01 - 0.1
            double correctionValue = (Math.max(penetration - slop, 0.0) / (a.invMass + b.invMass)) * percent;
            Vector2d correction = collisionNormal.scale(correctionValue);
            a.position -= correction.scale(a.invMass);
            b.position += correction.scale(b.invMass);
        }

        //Friction
        Vector2d rv = b.velocity - a.velocity;
        Vector2d invDot = rv.multiply(collisionNormal).reflect;
        Vector2d tangent = invDot.add(collisionNormal);
        tangent = tangent.normalize;

        double jt = -(rv.dotProduct(tangent));
        jt = jt / (a.invMass + b.invMass);

        if (jt != 0)
        {
            double mu = Math.hypot(a.staticFriction, b.staticFriction);

            Vector2d frictionImpulse;
            if (Math.abs(jt) < forceMomentumScalar * mu)
            {
                frictionImpulse = tangent.scale(jt);
            }

            else
            {
                auto dynamicFriction = Math.hypot(a.dynamicFriction, b.dynamicFriction);
                frictionImpulse = tangent.scale(-forceMomentumScalar).scale(dynamicFriction);
            }

            a.velocity -= frictionImpulse.scale(a.invMass).min(maxValue);
            b.velocity += frictionImpulse.scale(b.invMass).min(maxValue);
        }

    }

    bool collisionAABB(Rectangle a, Rectangle b, out CollisionResult result)
    {
        Rect2d abox = a.bounds;
        Rect2d bbox = b.bounds;

        Vector2d n = a.center.subtract(b.center);

        double aExtent = abox.halfWidth;
        double bExtent = bbox.halfWidth;

        double xOverlap = aExtent + bExtent - Math.abs(Math.round(n.x));

        if (xOverlap >= 0)
        {
            aExtent = abox.halfHeight;
            bExtent = bbox.halfHeight;

            double y_overlap = aExtent + bExtent - Math.abs(n.y);
            if (y_overlap > 0)
            {
                if (xOverlap < y_overlap)
                {
                    Vector2d normal = n.x < 0 ? Vector2d(1, 0) : Vector2d(-1, 0);
                    const penetration = xOverlap;
                    result = CollisionResult(penetration, normal);
                }
                else
                {
                    Vector2d normal = n.y < 0 ? Vector2d(0, 1) : Vector2d(0, -1);
                    const penetration = y_overlap;
                    result = CollisionResult(penetration, normal);
                }
            }
        }

        return true;
    }

    bool collisionCircles(Circle a, Circle b, out CollisionResult result)
    {
        Vector2d aCenter = a.position.inc(a.radius);
        Vector2d bCenter = b.position.inc(b.radius);

        Vector2d n = bCenter.subtract(aCenter);

        double r = a.radius + b.radius;
        r *= r;

        double distanceSquared = n.magnitudeSquared;

        if (distanceSquared > r + 1.0)
        {
            return false;
        }

        double distance = n.magnitude;

        if (distance != 0)
        {
            double penetration = (a.radius + b.radius) - distance;
            Vector2d normal = n.div(distance);
            result = CollisionResult(penetration, normal);
        }
        else
        {
            double penetration = a.radius;
            const normal = Vector2d(1, 0);
            result = CollisionResult(penetration, normal);
        }

        return true;
    }

    bool collisionAABBvsCircle(Rectangle a, Circle b, out CollisionResult result)
    {
        Vector2d bCenter = b.center;
        Vector2d aCenter = a.center;

        Vector2d n = bCenter.subtract(aCenter);

        Vector2d closest = n;

        double x_extent = a.bounds.halfWidth;
        double y_extent = a.bounds.halfHeight;

        closest.x = Math.clamp(-x_extent, x_extent, closest.x);
        closest.y = Math.clamp(-y_extent, y_extent, closest.y);

        bool inside;

        // Circle inside AABB
        if (n == closest)
        {
            inside = true;

            if (Math.abs(n.x) > Math.abs(n.y))
            {
                closest.x = closest.x > 0 ? x_extent : -x_extent;
            }
            else
            {
                closest.y = closest.y > 0 ? y_extent : -y_extent;
            }
        }

        Vector2d closestPoint = aCenter.add(closest);
        Vector2d normal = bCenter - closestPoint;
        double distance = normal.magnitudeSquared;

        double r = b.radius;
        if (distance > r * r && !inside)
        {
            return false;
        }

        distance = Math.sqrt(distance);
        if (inside)
        {
            //-n
            normal = n.reflect.normalize;
            const penetration = Math.abs(b.radius - distance);
            result = CollisionResult(penetration, normal);
        }
        else
        {
            normal = n.normalize;
            const penetration = b.radius - distance;
            result = CollisionResult(penetration, normal);
        }

        return true;
    }
}
