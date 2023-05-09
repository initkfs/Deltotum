module deltotum.kit.sprites.animations.object.motion.circular_motion_transition;

import deltotum.kit.sprites.animations.object.value_transition: ValueTransition;
import deltotum.kit.sprites.sprite : Sprite;
import deltotum.kit.sprites.animations.interp.interpolator : Interpolator;
import deltotum.math.vector2d : Vector2d;
import math = deltotum.math;

/**
 * Authors: initkfs
 */
class CircularMotionTransition : ValueTransition
{
    private
    {
        double radius = 0;
        double centerX;
        double centerY;
    }

    this(Sprite obj, Vector2d center, double radius = 100, int timeMs = 200, Interpolator interpolator = null)
    {
        super(obj, 0, 360, timeMs, interpolator);
        this.radius = radius;
        centerX = center.x;
        centerY = center.y;
        onValue = (value) {
            obj.x = centerX + math.cosDeg(value) * radius;
            obj.y = centerY + math.sinDeg(value) * radius;
        };
    }
}