module deltotum.kit.sprites.animations.object.property.angle_transition;

import deltotum.kit.sprites.animations.object.value_transition: ValueTransition;
import deltotum.kit.sprites.animations.interp.interpolator: Interpolator;
import deltotum.kit.sprites.sprite: Sprite;

/**
 * Authors: initkfs
 */
class AngleTransition : ValueTransition
{
    this(Sprite obj, int timeMs, Interpolator interpolator = null)
    {
        super(obj, 0, 360, timeMs, interpolator);
        onValue = (value)
        {
            displayObject.angle = value;
        };
    }
}
