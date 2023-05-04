module deltotum.kit.sprites.animations.object.value_transition;

import deltotum.kit.sprites.animations.interp.interpolator : Interpolator;
import deltotum.kit.sprites.animations.object.display_object_transition : DisplayObjectTransition;
import deltotum.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
class ValueTransition : DisplayObjectTransition!double
{
    this(Sprite obj, double minValue = 0, double maxValue = 1, int timeMs = 200, Interpolator interpolator = null)
    {
        super(obj, minValue, maxValue, timeMs, interpolator);
    }
}
