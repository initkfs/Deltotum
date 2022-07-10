module deltotum.animation.object.value_transition;

import deltotum.animation.interp.interpolator : Interpolator;
import deltotum.animation.object.display_object_transition : DisplayObjectTransition;
import deltotum.display.display_object : DisplayObject;

/**
 * Authors: initkfs
 */
class ValueTransition : DisplayObjectTransition!double
{
    this(DisplayObject obj, double minValue = 0, double maxValue = 1, int timeMs = 200, Interpolator interpolator = null)
    {
        super(obj, minValue, maxValue, timeMs, interpolator);
    }
}
