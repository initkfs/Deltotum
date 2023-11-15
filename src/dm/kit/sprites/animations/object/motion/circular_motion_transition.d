module dm.kit.sprites.animations.object.motion.circular_motion_transition;

import dm.kit.sprites.animations.object.value_transition: ValueTransition;
import dm.kit.sprites.sprite : Sprite;
import dm.kit.sprites.animations.interp.interpolator : Interpolator;
import dm.math.vector2 : Vector2;
import math = dm.math;

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

    this(Sprite obj, Vector2 center, double radius = 100, int timeMs = 200, Interpolator interpolator = null)
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
