module deltotum.animation.object.motion.circular_motion_transition;

import deltotum.animation.object.value_transition: ValueTransition;
import deltotum.display.display_object : DisplayObject;
import deltotum.animation.interp.interpolator : Interpolator;
import deltotum.math.vector2d : Vector2d;
import deltotum.math.math : Math;

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
            obj.x = centerX + Math.cosDeg(value) * radius;
            obj.y = centerY + Math.sinDeg(value) * radius;
        };
    }
}
