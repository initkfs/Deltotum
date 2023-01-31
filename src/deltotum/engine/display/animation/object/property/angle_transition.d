module deltotum.engine.display.animation.object.property.angle_transition;

import deltotum.engine.display.animation.object.value_transition: ValueTransition;
import deltotum.engine.display.animation.interp.interpolator: Interpolator;
import deltotum.engine.display.display_object: DisplayObject;

/**
 * Authors: initkfs
 */
class AngleTransition : ValueTransition
{
    this(DisplayObject obj, int timeMs, Interpolator interpolator = null)
    {
        super(obj, 0, 360, timeMs, interpolator);
        onValue = (value)
        {
            displayObject.angle = value;
        };
    }
}
