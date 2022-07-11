module deltotum.animation.object.motion.circular_motion_transition;

import deltotum.animation.object.value_transition: ValueTransition;
import deltotum.display.display_object : DisplayObject;
import deltotum.animation.interp.interpolator : Interpolator;
import deltotum.math.vector2d : Vector2D;
import deltotum.math.math_util : MathUtil;

/**
 * Authors: initkfs
 */
class CircularMotionTransition : ValueTransition
{
    private
    {
        double currentAngleDeg = 0;
        double radius = 0;
        double centerX;
        double centerY;
    }

    this(DisplayObject obj, Vector2D center, double radius = 100, int timeMs = 200, Interpolator interpolator = null)
    {
        super(obj, 0, 360, timeMs, interpolator);
        this.radius = radius;
        centerX = center.x;
        centerY = center.y;
        onValue = (value) {
            obj.x = centerX + MathUtil.cosDeg(currentAngleDeg) * radius;
            obj.y = centerY + MathUtil.sinDeg(currentAngleDeg) * radius;
            currentAngleDeg++;
        };
    }
}
