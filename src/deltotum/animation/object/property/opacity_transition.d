module deltotum.animation.object.property.opacity_transition;

import deltotum.animation.object.display_object_transition: DisplayObjectTransition;
import deltotum.animation.interp.interpolator : Interpolator;
import deltotum.display.display_object: DisplayObject;

/**
 * Authors: initkfs
 */
class OpacityTransition : DisplayObjectTransition
{
    this(DisplayObject obj, int timeMs, Interpolator interpolator = null)
    {
        super(obj, 0, 1, timeMs, interpolator);
        onValue = (value)
        {
            displayObject.opacity = value;
        };
    }
}
