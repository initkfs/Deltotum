module deltotum.kit.display.animation.object.property.opacity_transition;

import deltotum.kit.display.animation.object.value_transition: ValueTransition;
import deltotum.kit.display.animation.interp.interpolator: Interpolator;
import deltotum.kit.display.display_object: DisplayObject;

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
