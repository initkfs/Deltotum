module api.dm.phys.steerings.steering_behavior;

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

    private Vec2d calcNewVelocity(Vec2d currentVelocity, Vec2d steeringForce, double maxVelocity) const @nogc nothrow pure @safe
    {
        const Vec2d newVelocity = (currentVelocity + steeringForce).truncate(maxVelocity);
        return newVelocity;
    }

    Vec2d seekForce(Vec2d position, Vec2d target, Vec2d currentVelocity, double maxVelocity) const @nogc nothrow pure @safe
    {
        const Vec2d targetDist = (target - position);
        //targetDist.magnitudeSquared
        if (targetDist.length <= distanceDelta)
        {
            return Vec2d.zero;
        }
        const Vec2d desiredVelocity = targetDist.normalize.scale(maxVelocity);
        const Vec2d steeringForce = desiredVelocity - currentVelocity;
        return steeringForce;
    }

    Vec2d seekVelocity(Vec2d position, Vec2d target, Vec2d currentVelocity, double maxVelocity) const @nogc nothrow pure @safe
    {
        const Vec2d steeringForce = seekForce(position, target, currentVelocity, maxVelocity);
        if (steeringForce.isZero)
        {
            return steeringForce;
        }

        const Vec2d newVelocity = calcNewVelocity(currentVelocity, steeringForce, maxVelocity);
        return newVelocity;
    }

    Vec2d fleeForce(Vec2d position, Vec2d target, Vec2d currentVelocity, double maxVelocity) const @nogc nothrow pure @safe
    {
        const Vec2d desiredVelocity = (position - target).normalize.scale(maxVelocity);
        const Vec2d steeringForce = desiredVelocity - currentVelocity;
        return steeringForce;
    }

    Vec2d fleeVelocity(Vec2d position, Vec2d target, Vec2d currentVelocity, double maxVelocity) const @nogc nothrow pure @safe
    {
        const Vec2d steeringForce = fleeForce(position, target, currentVelocity, maxVelocity);
        const Vec2d newVelocity = calcNewVelocity(currentVelocity, steeringForce, maxVelocity);
        return newVelocity;
    }

    Vec2d arrivalForce(Vec2d position, Vec2d target, Vec2d currentVelocity, double arriveRadius, double maxVelocity) const @nogc nothrow pure @safe
    {
        Vec2d desiredVelocity = target - position;
        const double distance = desiredVelocity.magnitude;

        desiredVelocity = desiredVelocity.normalize;

        double scaleFactor = maxVelocity;
        if (distance < arriveRadius)
        {
            scaleFactor = maxVelocity * (distance / arriveRadius);
        }

        desiredVelocity = desiredVelocity.scale(scaleFactor);

        const Vec2d steeringForce = desiredVelocity - currentVelocity;
        return steeringForce;
    }

    Vec2d arrivalVelocity(Vec2d position, Vec2d target, Vec2d currentVelocity, double arriveRadius, double maxVelocity) const @nogc nothrow pure @safe
    {
        const Vec2d steeringForce = arrivalForce(position, target, currentVelocity, arriveRadius, maxVelocity);

        const Vec2d newVelocity = calcNewVelocity(currentVelocity, steeringForce, maxVelocity);
        return newVelocity;
    }

    WanderState wanderForce(
        Vec2d velocity,
        WanderCircle circle,
        WanderAngle angle,
        Random rnd) const pure @safe
    {
        const Vec2d circleCenter = velocity.normalize.scale(circle.distance);
        Vec2d displacement = Vec2d(0, -1).scale(circle.radius);

        displacement = Vec2d.fromPolarDeg(angle.angleDeg, displacement.magnitude);
        const angleDiff = rnd.randomBetween0to1 * angle.angleChange - angle.angleChange * 0.5;

        auto newAngleDeg = (angle.angleDeg + angleDiff * angle.andleVariation) % 360;

        const Vec2d wanderForce = circleCenter + displacement;
        return WanderState(wanderForce, angle.angleDeg, newAngleDeg);
    }

    WanderState wander(
        Vec2d currentVelocity,
        double maxVelocity,
        WanderCircle circle,
        WanderAngle angle,
        Random rnd
    ) const pure @safe
    {
        const wanderForce = wanderForce(currentVelocity, circle, angle, rnd);

        const Vec2d newVelocity = calcNewVelocity(currentVelocity, wanderForce.velocity, maxVelocity);
        return WanderState(newVelocity, wanderForce.oldWanderAngleDeg, wanderForce
                .newWanderAngleDeg);
    }

    Vec2d pursuitForce(Vec2d position, Vec2d targetPosition, Vec2d currentVelocity, Vec2d targetVelocity, double maxVelocity) const @nogc nothrow pure @safe
    {
        import math = api.dm.math;

        const predictionDistance = Math.abs(position.distanceTo(targetPosition) / maxVelocity);

        const Vec2d futurePosition = targetPosition + targetVelocity.scale(predictionDistance);
        return seekForce(position, futurePosition, currentVelocity, maxVelocity);
    }

    Vec2d pursuitVelocity(Vec2d position, Vec2d target, Vec2d currentVelocity, Vec2d targetVelocity, double maxVelocity) const @nogc nothrow pure @safe
    {
        const Vec2d steeringForce = pursuitForce(position, target, currentVelocity, targetVelocity, maxVelocity);

        const Vec2d newVelocity = calcNewVelocity(currentVelocity, steeringForce, maxVelocity);
        return newVelocity;
    }

    Vec2d evadeForce(Vec2d position, Vec2d target, Vec2d currentVelocity, Vec2d targetVelocity, double maxVelocity) const @nogc nothrow pure @safe
    {
        //TODO remove code duplication with pursuitForce
        const predictionDistance = Math.abs(position.distanceTo(target) / maxVelocity);
        Vec2d futurePosition = target + targetVelocity.scale(predictionDistance);
        return fleeForce(position, futurePosition, currentVelocity, maxVelocity);
    }

    Vec2d evadeVelocity(Vec2d position, Vec2d target, Vec2d currentVelocity, Vec2d targetVelocity, double maxVelocity) const @nogc nothrow pure @safe
    {
        const Vec2d steeringForce = evadeForce(position, target, currentVelocity, targetVelocity, maxVelocity);

        const Vec2d newVelocity = calcNewVelocity(currentVelocity, steeringForce, maxVelocity);
        return newVelocity;
    }
}
