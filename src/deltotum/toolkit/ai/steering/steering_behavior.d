module deltotum.toolkit.ai.steering.steering_behavior;

import deltotum.math.vector2d : Vector2d;
import deltotum.math.random : Random;

/**
 * Authors: initkfs
 */
class SteeringBehavior
{
    private
    {
        Random random;
    }

    this(Random random)
    {
        this.random = random;
    }

    private Vector2d calculateNewVelocity(Vector2d currentVelocity, Vector2d steeringForce, double maxVelocity) const @nogc nothrow pure @safe
    {
        const Vector2d newVelocity = (currentVelocity + steeringForce).truncate(maxVelocity);
        return newVelocity;
    }

    Vector2d seekForce(Vector2d position, Vector2d target, Vector2d currentVelocity, double maxVelocity) const @nogc nothrow pure @safe
    {
        const Vector2d desiredVelocity = (target - position).normalize.scale(maxVelocity);
        const Vector2d steeringForce = desiredVelocity - currentVelocity;
        return steeringForce;
    }

    Vector2d seek(Vector2d position, Vector2d target, Vector2d currentVelocity, double maxVelocity) const @nogc nothrow pure @safe
    {
        const Vector2d steeringForce = seekForce(position, target, currentVelocity, maxVelocity);
        const Vector2d newVelocity = calculateNewVelocity(currentVelocity, steeringForce, maxVelocity);
        return newVelocity;
    }

    Vector2d fleeForce(Vector2d position, Vector2d target, Vector2d currentVelocity, double maxVelocity) const @nogc nothrow pure @safe
    {
        const Vector2d desiredVelocity = (position - target).normalize.scale(maxVelocity);
        const Vector2d steeringForce = desiredVelocity - currentVelocity;
        return steeringForce;
    }

    Vector2d flee(Vector2d position, Vector2d target, Vector2d currentVelocity, double maxVelocity) const @nogc nothrow pure @safe
    {
        const Vector2d steeringForce = fleeForce(position, target, currentVelocity, maxVelocity);
        const Vector2d newVelocity = calculateNewVelocity(currentVelocity, steeringForce, maxVelocity);
        return newVelocity;
    }

    Vector2d arriveForce(Vector2d position, Vector2d target, Vector2d currentVelocity, double arriveRadius, double maxVelocity) const @nogc nothrow pure @safe
    {
        Vector2d desiredVelocity = target - position;
        const double distance = desiredVelocity.magnitude;
        desiredVelocity = desiredVelocity.normalize;
        double scaleFactor = maxVelocity;
        if (distance < arriveRadius)
        {
            scaleFactor = maxVelocity * (distance / arriveRadius);

        }
        desiredVelocity = desiredVelocity.scale(scaleFactor);
        const Vector2d steeringForce = desiredVelocity - currentVelocity;
        return steeringForce;
    }

    Vector2d arrive(Vector2d position, Vector2d target, Vector2d currentVelocity, double arriveRadius, double maxVelocity) const @nogc nothrow pure @safe
    {
        const Vector2d steeringForce = arriveForce(position, target, currentVelocity, arriveRadius, maxVelocity);
        const Vector2d newVelocity = calculateNewVelocity(currentVelocity, steeringForce, maxVelocity);
        return newVelocity;
    }

    Vector2d wanderForce(Vector2d velocity, double wanderAngle, double wandlerCircleDistance = 30, double wanderCircleRadius = 10, double angleChange = 1.0) const @nogc nothrow pure @safe
    {
        const Vector2d circleCenter = velocity.clone.normalize.scale(wandlerCircleDistance);
        Vector2d displacement = Vector2d(0, -1).scale(wanderCircleRadius);

        displacement = displacement.polar(wanderAngle, displacement.magnitude);
        //const angleDiff = random.randomBetween0to1 * angleChange - angleChange * 0.5;
        //newAngle = newAngle.inc(angleDiff);
        const Vector2d wanderForce = circleCenter + displacement;
        return wanderForce;
    }

    Vector2d wander(Vector2d currentVelocity, double maxVelocity, double wanderAngle, double wandlerCircleDistance = 30, double wanderCircleRadius = 10, double angleChange = 1.0) const @nogc nothrow pure @safe
    {
        const Vector2d wanderForce = wanderForce(currentVelocity, wanderAngle, wandlerCircleDistance, wanderCircleRadius, angleChange);
        const Vector2d newVelocity = calculateNewVelocity(currentVelocity, wanderForce, maxVelocity);
        return newVelocity;
    }

    Vector2d pursuitForce(Vector2d position, Vector2d target, Vector2d currentVelocity, Vector2d targetVelocity, double maxVelocity) const @nogc nothrow pure @safe
    {
        import math = deltotum.math.math;

        const predictionDistance = math.abs(position.distanceTo(target) / maxVelocity);
        const Vector2d futurePosition = position + targetVelocity.scale(predictionDistance);
        return seekForce(position, futurePosition, currentVelocity, maxVelocity);
    }

    Vector2d pursuit(Vector2d position, Vector2d target, Vector2d currentVelocity, Vector2d targetVelocity, double maxVelocity) const @nogc nothrow pure @safe
    {
        const Vector2d steeringForce = pursuitForce(position, target, currentVelocity, targetVelocity, maxVelocity);
        const Vector2d newVelocity = calculateNewVelocity(currentVelocity, steeringForce, maxVelocity);
        return newVelocity;
    }

    Vector2d evadeForce(Vector2d position, Vector2d target, Vector2d currentVelocity, Vector2d targetVelocity, double maxVelocity) const @nogc nothrow pure @safe
    {
        import math = deltotum.math.math;
        //TODO remove code duplication with pursuitForce
        const predictionDistance = math.abs(position.distanceTo(target) / maxVelocity);
        Vector2d futurePosition = position + targetVelocity.scale(predictionDistance);
        return fleeForce(position, futurePosition, currentVelocity, maxVelocity);
    }

    Vector2d evade(Vector2d position, Vector2d target, Vector2d currentVelocity, Vector2d targetVelocity, double maxVelocity) const @nogc nothrow pure @safe
    {
        const Vector2d steeringForce = evadeForce(position, target, currentVelocity, targetVelocity, maxVelocity);
        const Vector2d newVelocity = calculateNewVelocity(currentVelocity, steeringForce, maxVelocity);
        return newVelocity;
    }
}
