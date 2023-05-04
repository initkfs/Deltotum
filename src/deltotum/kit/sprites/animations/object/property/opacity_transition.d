module deltotum.kit.sprites.animations.object.property.opacity_transition;

import deltotum.kit.sprites.animations.object.value_transition: ValueTransition;
import deltotum.kit.sprites.animations.interp.interpolator: Interpolator;
import deltotum.kit.sprites.sprite: Sprite;

/**
 * Authors: initkfs
 */
class OpacityTransition : ValueTransition
{
    this(Sprite obj, int timeMs, Interpolator interpolator = null)
    {
        super(obj, 0.0, 1.0, timeMs, interpolator);
        onValue = (value)
        {
            displayObject.opacity = value;
        };
    }
}
