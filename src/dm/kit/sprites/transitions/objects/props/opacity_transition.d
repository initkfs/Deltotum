module dm.kit.sprites.transitions.objects.props.opacity_transition;

import dm.kit.sprites.transitions.objects.value_transition : ValueTransition;
import dm.math.interps.interpolator : Interpolator;

/**
 * Authors: initkfs
 */
class OpacityTransition : ValueTransition
{
    this(int timeMs, Interpolator interpolator = null)
    {
        super(0.0, 1.0, timeMs, interpolator);

        isInverse = true;

        onOldNewValue ~= (oldValue, value) {
            onObjects((object) { object.opacity = value; });
        };
    }
}
