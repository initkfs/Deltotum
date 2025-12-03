module api.dm.phys.steerings.steering_behavior;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.math.geom2.vec2 : Vec2d;
import api.math.random : Random;

import Math = api.math;

struct WanderState
{
    Vec2d velocity;
    double oldWanderAngleDeg = 0;
    double newWanderAngleDeg = 0;
}

struct WanderCircle
{
    double distance = 0;
    double radius = 0;
}

struct WanderAngle
{
    double angleDeg = 0;
    double angleChange = 0.5;
    double andleVariation = 10;
}

/**
 * Authors: initkfs
 * https://habr.com/ru/articles/358366/
 * https://habr.com/ru/articles/358460/
 */
class SteeringBehavior
{
    double distanceDelta = 3;
    double defaultMaxVelocity = 50;

    protected Vec2d calcNewVelocity(Vec2d oldVelocity, Vec2d steeringForce, double maxVelocity = defaultMaxVelocity) const nothrow @safe
    {
        //TODO steeringForce.truncate maxForce
        const Vec2d newVelocity = (oldVelocity + steeringForce).truncate(maxVelocity);
        return newVelocity;
    }

    Vec2d seekForce(Vec2d spritePos, Vec2d spriteVelocity, Vec2d targetPos, double maxVelocity = defaultMaxVelocity) const nothrow @safe
    {
        const Vec2d targetDist = (targetPos - spritePos);
        //targetDist.lengthSquared
        if (targetDist.length <= distanceDelta)
        {
            return Vec2d.zero;
        }
        const Vec2d desiredVelocity = targetDist.normalize.scale(maxVelocity);
        const Vec2d steeringForce = desiredVelocity - spriteVelocity;
        return steeringForce;
    }

    Vec2d seekVelocity(Vec2d spritePos, Vec2d spriteVelocity, Vec2d targetPos, double maxVelocity = defaultMaxVelocity) const nothrow @safe
    {
        const Vec2d steeringForce = seekForce(spritePos, spriteVelocity, targetPos, maxVelocity);
        if (steeringForce.isZero)
        {
            return steeringForce;
        }

        const Vec2d newVelocity = calcNewVelocity(spriteVelocity, steeringForce, maxVelocity);
        return newVelocity;
    }

    Vec2d fleeForce(Vec2d spritePos, Vec2d spriteVelocity, Vec2d targetPos, double maxVelocity = defaultMaxVelocity) const nothrow @safe
    {
        const Vec2d desiredVelocity = (spritePos - targetPos).normalize.scale(maxVelocity);
        const Vec2d steeringForce = desiredVelocity - spriteVelocity;
        return steeringForce;
    }

    Vec2d fleeVelocity(Vec2d spritePos, Vec2d spriteVelocity, Vec2d targetPos, double maxVelocity = defaultMaxVelocity) const nothrow @safe
    {
        const Vec2d steeringForce = fleeForce(spritePos, spriteVelocity, targetPos, maxVelocity);
        const Vec2d newVelocity = calcNewVelocity(spriteVelocity, steeringForce, maxVelocity);
        return newVelocity;
    }

    Vec2d arrivalForce(Vec2d spritePos, Vec2d spriteVelocity, Vec2d targetPos, double arriveRadius, double maxVelocity = defaultMaxVelocity) const nothrow @safe
    {
        Vec2d desiredVelocity = targetPos - spritePos;
        const double distance = desiredVelocity.length;

        desiredVelocity = desiredVelocity.normalize;

        double scaleFactor = maxVelocity;
        if (distance < arriveRadius)
        {
            scaleFactor = scaleFactor * (distance / arriveRadius);
        }

        desiredVelocity = desiredVelocity.scale(scaleFactor);

        const Vec2d steeringForce = desiredVelocity - spriteVelocity;
        return steeringForce;
    }

    Vec2d arrivalVelocity(Vec2d spritePos, Vec2d spriteVelocity, Vec2d targetPos, double arriveRadius, double maxVelocity = defaultMaxVelocity) const nothrow @safe
    {
        const Vec2d steeringForce = arrivalForce(spritePos, spriteVelocity, targetPos, arriveRadius, maxVelocity);

        const Vec2d newVelocity = calcNewVelocity(spriteVelocity, steeringForce, maxVelocity);
        return newVelocity;
    }

    WanderState wanderForce(
        Vec2d velocity,
        WanderCircle circle,
        WanderAngle angle,
        Random rnd) const @safe
    {
        const Vec2d circleCenter = velocity.normalize.scale(circle.distance);
        Vec2d displacement = Vec2d(0, -1).scale(circle.radius);

        displacement = Vec2d.fromPolarDeg(angle.angleDeg, displacement.length);
        const angleDiff = rnd.between0to1 * angle.angleChange - angle.angleChange * 0.5;

        auto newAngleDeg = (angle.angleDeg + angleDiff * angle.andleVariation) % 360;

        const Vec2d wanderForce = circleCenter + displacement;
        return WanderState(wanderForce, angle.angleDeg, newAngleDeg);
    }

    WanderState wander(
        Vec2d currentVelocity,
        WanderCircle circle,
        WanderAngle angle,
        Random rnd,
        double maxVelocity = defaultMaxVelocity
    ) const @safe
    {
        const wanderForce = wanderForce(currentVelocity, circle, angle, rnd);

        const Vec2d newVelocity = calcNewVelocity(currentVelocity, wanderForce.velocity, maxVelocity);
        return WanderState(newVelocity, wanderForce.oldWanderAngleDeg, wanderForce
                .newWanderAngleDeg);
    }

    Vec2d pursuitForce(Vec2d spritePos, Vec2d spriteVelocity, Vec2d targetPos, Vec2d targetVelocity, double maxVelocity = defaultMaxVelocity) const nothrow @safe
    {
        import math = api.dm.math;

        const predictionDistance = Math.abs(spritePos.distanceTo(targetPos) / maxVelocity);

        const Vec2d futurePosition = targetPos + targetVelocity.scale(predictionDistance);
        return seekForce(spritePos, spriteVelocity, futurePosition, maxVelocity);
    }

    Vec2d pursuitVelocity(Vec2d spritePos, Vec2d spriteVelocity, Vec2d targetPos, Vec2d targetVelocity, double maxVelocity = defaultMaxVelocity) const nothrow @safe
    {
        const Vec2d steeringForce = pursuitForce(spritePos, spriteVelocity, targetPos, targetVelocity, maxVelocity);

        const Vec2d newVelocity = calcNewVelocity(spriteVelocity, steeringForce, maxVelocity);
        return newVelocity;
    }

    Vec2d evadeForce(Vec2d spritePos, Vec2d spriteVelocity, Vec2d targetPos, Vec2d targetVelocity, double maxVelocity = defaultMaxVelocity) const nothrow @safe
    {
        //TODO remove code duplication with pursuitForce
        const predictionDistance = Math.abs(spritePos.distanceTo(targetPos) / maxVelocity);
        Vec2d futurePosition = targetPos + targetVelocity.scale(predictionDistance);
        return fleeForce(spritePos, spriteVelocity, futurePosition, maxVelocity);
    }

    Vec2d evadeVelocity(Vec2d spritePos, Vec2d spriteVelocity, Vec2d targetPos, Vec2d targetVelocity, double maxVelocity = defaultMaxVelocity) const nothrow @safe
    {
        const Vec2d steeringForce = evadeForce(spritePos, spriteVelocity, targetPos, targetVelocity, maxVelocity);

        const Vec2d newVelocity = calcNewVelocity(spriteVelocity, steeringForce, maxVelocity);
        return newVelocity;
    }

    Vec2d followLeaderVelocity(Vec2d leaderPosition, Vec2d leaderVelocity, double behindLeaderDist = 10, Vec2d targetPosition, Vec2d targetVelocity, double arriveRadius = 20, double maxVelocity = defaultMaxVelocity)
    {
        const tv = leaderVelocity.scale(-1).normalize.scale(behindLeaderDist);
        const behind = leaderPosition + tv;

        // Создание силы для прибытия в точку behind
        const Vec2d force = arrivalVelocity(targetPosition, behind, targetVelocity, arriveRadius, maxVelocity);

        //force.add(separation());

        return force;
    }

    Vec2d alignmentForce(Sprite2d sprite, Sprite2d[] neighbors, double distance = 30, double maxVelocity = defaultMaxVelocity)
    {
        size_t neighborCount;

        Vec2d force;

        const spritePos = sprite.pos;
        foreach (neighbor; neighbors)
        {
            const neighborPos = neighbor.pos;
            if (spritePos.distanceTo(neighborPos) <= distance)
            {
                force.x += neighbor.velocity.x;
                force.y += neighbor.velocity.y;
                neighborCount++;
            }
        }

        if (neighborCount == 0)
        {
            return force;
        }

        force.x /= neighborCount;
        force.y /= neighborCount;

        force = force.normalize.scale(maxVelocity);

        return force;
    }

    Vec2d cohesionForce(Sprite2d sprite, Sprite2d[] neighbors, double distance = 30, double maxCohesion)
    {
        size_t neighborCount;

        Vec2d force;

        const spritePos = sprite.pos;
        foreach (neighbor; neighbors)
        {
            const neighborPos = neighbor.pos;
            if (spritePos.distanceTo(neighborPos) <= distance)
            {
                force.x += neighbor.x;
                force.y += neighbor.y;
                neighborCount++;
            }
        }

        if (neighborCount == 0)
        {
            return force;
        }

        force.x /= neighborCount;
        force.y /= neighborCount;

        force = Vec2d(force.x - spritePos.x, force.y - spritePos.y).normalize.scale(maxCohesion);

        return force;
    }

    Vec2d separationForce(Sprite2d sprite, Sprite2d[] neighbors, double distance = 30, double maxSeparation = 50)
    {
        size_t neighborCount;
        Vec2d force;

        const spritePos = sprite.pos;
        foreach (neighbor; neighbors)
        {
            const neighborPos = neighbor.pos;
            const dist = spritePos.distanceTo(neighborPos);
            if (dist <= distance)
            {
                force.x += neighbor.x - spritePos.x;
                force.y += neighbor.y - spritePos.y;
                neighborCount++;
            }
        }

        if (neighborCount == 0)
        {
            return Vec2d.zero;
        }

        force.x /= neighborCount;
        force.y /= neighborCount;

        force = force.scale(-1);

        force = force.normalize.scale(maxSeparation);

        return force;
    }

    Vec2d acs(Sprite2d sprite, Sprite2d[] neighbors, double distance = 30, double maxSeparation = 100, double maxVelocity = 100, double alignmentWeight = 1, double cohesionWeight = 1, double separationWeight = 1)
    {
        const alignment = alignmentForce(sprite, neighbors, distance, maxVelocity);
        const cohesion = cohesionForce(sprite, neighbors, distance, maxSeparation);
        const separation = separationForce(sprite, neighbors, distance, maxSeparation);

        Vec2d velocity;

        velocity.x += alignment.x * alignmentWeight + cohesion.x * cohesionWeight + separation.x * separationWeight;

        velocity.y += alignment.y * alignmentWeight + cohesion.y * cohesionWeight + separation.y * separationWeight;

        return calcNewVelocity(sprite.velocity, velocity, maxVelocity);
    }
}
