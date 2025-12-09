module api.dm.phys.steerings.steering_behavior;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.math.geom2.vec2 : Vec2f;
import api.math.random : Random;

import Math = api.math;

struct WanderState
{
    Vec2f velocity;
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

    protected Vec2f calcNewVelocity(Vec2f oldVelocity, Vec2f steeringForce, double maxVelocity = defaultMaxVelocity) const nothrow @safe
    {
        //TODO steeringForce.truncate maxForce
        const Vec2f newVelocity = (oldVelocity + steeringForce).truncate(maxVelocity);
        return newVelocity;
    }

    Vec2f seekForce(Vec2f spritePos, Vec2f spriteVelocity, Vec2f targetPos, double maxVelocity = defaultMaxVelocity) const nothrow @safe
    {
        const Vec2f targetDist = (targetPos - spritePos);
        //targetDist.lengthSquared
        if (targetDist.length <= distanceDelta)
        {
            return Vec2f.zero;
        }
        const Vec2f desiredVelocity = targetDist.normalize.scale(maxVelocity);
        const Vec2f steeringForce = desiredVelocity - spriteVelocity;
        return steeringForce;
    }

    Vec2f seekVelocity(Vec2f spritePos, Vec2f spriteVelocity, Vec2f targetPos, double maxVelocity = defaultMaxVelocity) const nothrow @safe
    {
        const Vec2f steeringForce = seekForce(spritePos, spriteVelocity, targetPos, maxVelocity);
        if (steeringForce.isZero)
        {
            return steeringForce;
        }

        const Vec2f newVelocity = calcNewVelocity(spriteVelocity, steeringForce, maxVelocity);
        return newVelocity;
    }

    Vec2f fleeForce(Vec2f spritePos, Vec2f spriteVelocity, Vec2f targetPos, double maxVelocity = defaultMaxVelocity) const nothrow @safe
    {
        const Vec2f desiredVelocity = (spritePos - targetPos).normalize.scale(maxVelocity);
        const Vec2f steeringForce = desiredVelocity - spriteVelocity;
        return steeringForce;
    }

    Vec2f fleeVelocity(Vec2f spritePos, Vec2f spriteVelocity, Vec2f targetPos, double maxVelocity = defaultMaxVelocity) const nothrow @safe
    {
        const Vec2f steeringForce = fleeForce(spritePos, spriteVelocity, targetPos, maxVelocity);
        const Vec2f newVelocity = calcNewVelocity(spriteVelocity, steeringForce, maxVelocity);
        return newVelocity;
    }

    Vec2f arrivalForce(Vec2f spritePos, Vec2f spriteVelocity, Vec2f targetPos, double arriveRadius, double maxVelocity = defaultMaxVelocity) const nothrow @safe
    {
        Vec2f desiredVelocity = targetPos - spritePos;
        const double distance = desiredVelocity.length;

        desiredVelocity = desiredVelocity.normalize;

        double scaleFactor = maxVelocity;
        if (distance < arriveRadius)
        {
            scaleFactor = scaleFactor * (distance / arriveRadius);
        }

        desiredVelocity = desiredVelocity.scale(scaleFactor);

        const Vec2f steeringForce = desiredVelocity - spriteVelocity;
        return steeringForce;
    }

    Vec2f arrivalVelocity(Vec2f spritePos, Vec2f spriteVelocity, Vec2f targetPos, double arriveRadius, double maxVelocity = defaultMaxVelocity) const nothrow @safe
    {
        const Vec2f steeringForce = arrivalForce(spritePos, spriteVelocity, targetPos, arriveRadius, maxVelocity);

        const Vec2f newVelocity = calcNewVelocity(spriteVelocity, steeringForce, maxVelocity);
        return newVelocity;
    }

    WanderState wanderForce(
        Vec2f velocity,
        WanderCircle circle,
        WanderAngle angle,
        Random rnd) const @safe
    {
        const Vec2f circleCenter = velocity.normalize.scale(circle.distance);
        Vec2f displacement = Vec2f(0, -1).scale(circle.radius);

        displacement = Vec2f.fromPolarDeg(angle.angleDeg, displacement.length);
        const angleDiff = rnd.between0to1 * angle.angleChange - angle.angleChange * 0.5;

        auto newAngleDeg = (angle.angleDeg + angleDiff * angle.andleVariation) % 360;

        const Vec2f wanderForce = circleCenter + displacement;
        return WanderState(wanderForce, angle.angleDeg, newAngleDeg);
    }

    WanderState wander(
        Vec2f currentVelocity,
        WanderCircle circle,
        WanderAngle angle,
        Random rnd,
        double maxVelocity = defaultMaxVelocity
    ) const @safe
    {
        const wanderForce = wanderForce(currentVelocity, circle, angle, rnd);

        const Vec2f newVelocity = calcNewVelocity(currentVelocity, wanderForce.velocity, maxVelocity);
        return WanderState(newVelocity, wanderForce.oldWanderAngleDeg, wanderForce
                .newWanderAngleDeg);
    }

    Vec2f pursuitForce(Vec2f spritePos, Vec2f spriteVelocity, Vec2f targetPos, Vec2f targetVelocity, double maxVelocity = defaultMaxVelocity) const nothrow @safe
    {
        import math = api.dm.math;

        const predictionDistance = Math.abs(spritePos.distanceTo(targetPos) / maxVelocity);

        const Vec2f futurePosition = targetPos + targetVelocity.scale(predictionDistance);
        return seekForce(spritePos, spriteVelocity, futurePosition, maxVelocity);
    }

    Vec2f pursuitVelocity(Vec2f spritePos, Vec2f spriteVelocity, Vec2f targetPos, Vec2f targetVelocity, double maxVelocity = defaultMaxVelocity) const nothrow @safe
    {
        const Vec2f steeringForce = pursuitForce(spritePos, spriteVelocity, targetPos, targetVelocity, maxVelocity);

        const Vec2f newVelocity = calcNewVelocity(spriteVelocity, steeringForce, maxVelocity);
        return newVelocity;
    }

    Vec2f evadeForce(Vec2f spritePos, Vec2f spriteVelocity, Vec2f targetPos, Vec2f targetVelocity, double maxVelocity = defaultMaxVelocity) const nothrow @safe
    {
        //TODO remove code duplication with pursuitForce
        const predictionDistance = Math.abs(spritePos.distanceTo(targetPos) / maxVelocity);
        Vec2f futurePosition = targetPos + targetVelocity.scale(predictionDistance);
        return fleeForce(spritePos, spriteVelocity, futurePosition, maxVelocity);
    }

    Vec2f evadeVelocity(Vec2f spritePos, Vec2f spriteVelocity, Vec2f targetPos, Vec2f targetVelocity, double maxVelocity = defaultMaxVelocity) const nothrow @safe
    {
        const Vec2f steeringForce = evadeForce(spritePos, spriteVelocity, targetPos, targetVelocity, maxVelocity);

        const Vec2f newVelocity = calcNewVelocity(spriteVelocity, steeringForce, maxVelocity);
        return newVelocity;
    }

    Vec2f followLeaderVelocity(Vec2f leaderPosition, Vec2f leaderVelocity, double behindLeaderDist = 10, Vec2f targetPosition, Vec2f targetVelocity, double arriveRadius = 20, double maxVelocity = defaultMaxVelocity)
    {
        const tv = leaderVelocity.scale(-1).normalize.scale(behindLeaderDist);
        const behind = leaderPosition + tv;

        // Создание силы для прибытия в точку behind
        const Vec2f force = arrivalVelocity(targetPosition, behind, targetVelocity, arriveRadius, maxVelocity);

        //force.add(separation());

        return force;
    }

    Vec2f alignmentForce(Sprite2d sprite, Sprite2d[] neighbors, double distance = 30, double maxVelocity = defaultMaxVelocity)
    {
        size_t neighborCount;

        Vec2f force;

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

    Vec2f cohesionForce(Sprite2d sprite, Sprite2d[] neighbors, double distance = 30, double maxCohesion)
    {
        size_t neighborCount;

        Vec2f force;

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

        force = Vec2f(force.x - spritePos.x, force.y - spritePos.y).normalize.scale(maxCohesion);

        return force;
    }

    Vec2f separationForce(Sprite2d sprite, Sprite2d[] neighbors, double distance = 30, double maxSeparation = 50)
    {
        size_t neighborCount;
        Vec2f force;

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
            return Vec2f.zero;
        }

        force.x /= neighborCount;
        force.y /= neighborCount;

        force = force.scale(-1);

        force = force.normalize.scale(maxSeparation);

        return force;
    }

    Vec2f acs(Sprite2d sprite, Sprite2d[] neighbors, double distance = 30, double maxSeparation = 100, double maxVelocity = 100, double alignmentWeight = 1, double cohesionWeight = 1, double separationWeight = 1)
    {
        const alignment = alignmentForce(sprite, neighbors, distance, maxVelocity);
        const cohesion = cohesionForce(sprite, neighbors, distance, maxSeparation);
        const separation = separationForce(sprite, neighbors, distance, maxSeparation);

        Vec2f velocity;

        velocity.x += alignment.x * alignmentWeight + cohesion.x * cohesionWeight + separation.x * separationWeight;

        velocity.y += alignment.y * alignmentWeight + cohesion.y * cohesionWeight + separation.y * separationWeight;

        return calcNewVelocity(sprite.velocity, velocity, maxVelocity);
    }
}
