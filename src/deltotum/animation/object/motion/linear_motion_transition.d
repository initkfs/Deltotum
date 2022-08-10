module deltotum.animation.object.motion.linear_motion_transition;

import deltotum.animation.object.display_object_transition : DisplayObjectTransition;
import deltotum.display.display_object : DisplayObject;
import deltotum.animation.interp.interpolator : Interpolator;
import deltotum.math.vector2d : Vector2d;

/**
 * Authors: initkfs
 */
class LinearMotionTransition : DisplayObjectTransition!Vector2d
{
    this(DisplayObject obj, Vector2d start, Vector2d end, int timeMs = 200, Interpolator interpolator = null)
    {
        super(obj, start, end, timeMs, interpolator);
        onValue = (value)
        {
            displayObject.x = value.x;
            displayObject.y = value.y;
        };
    }
}
