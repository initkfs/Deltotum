module deltotum.animation.object.display_object_transition;

import deltotum.display.display_object : DisplayObject;
import deltotum.animation.interp.interpolator : Interpolator;
import deltotum.animation.interp.uni_interpolator : UniInterpolator;
import deltotum.animation.transition: Transition;

/**
 * Authors: initkfs
 */
class DisplayObjectTransition : Transition
{
    protected
    {
        @property DisplayObject displayObject;
    }

    this(DisplayObject obj, double minValue, double maxValue, int timeMs, Interpolator interpolator = null)
    {
        super(minValue, maxValue, timeMs, interpolator);
        this.displayObject = obj;
    }

    override void destroy()
    {
        super.destroy;
        displayObject = null;
    }

}
