module deltotum.engine.display.animation.object.motion.linear_motion_transition;

import deltotum.engine.display.animation.object.display_object_transition : DisplayObjectTransition;
import deltotum.engine.display.display_object : DisplayObject;
import deltotum.engine.display.animation.interp.interpolator : Interpolator;
import deltotum.core.maths.vector2d : Vector2d;

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
