module deltotum.animation.object.property.opacity_transition;

import deltotum.animation.object.value_transition: ValueTransition;
import deltotum.animation.interp.interpolator: Interpolator;
import deltotum.display.display_object: DisplayObject;

/**
 * Authors: initkfs
 */
class OpacityTransition : ValueTransition
{
    this(DisplayObject obj, int timeMs, Interpolator interpolator = null)
    {
        super(obj, 0.0, 1.0, timeMs, interpolator);
        onValue = (value)
        {
            displayObject.opacity = value;
        };
    }
}
