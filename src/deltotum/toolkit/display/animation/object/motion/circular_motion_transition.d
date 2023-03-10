module deltotum.toolkit.display.animation.object.motion.circular_motion_transition;

import deltotum.toolkit.display.animation.object.value_transition: ValueTransition;
import deltotum.toolkit.display.display_object : DisplayObject;
import deltotum.toolkit.display.animation.interp.interpolator : Interpolator;
import deltotum.maths.vector2d : Vector2d;
import math = deltotum.maths.math;

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

    this(DisplayObject obj, Vector2d center, double radius = 100, int timeMs = 200, Interpolator interpolator = null)
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
