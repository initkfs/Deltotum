module api.dm.kit.sprites.transitions.objects.props.opacity_transition;

import api.dm.kit.sprites.transitions.objects.value_transition : ValueTransition;
import api.math.interps.interpolator : Interpolator;

/**
 * Authors: initkfs
 */
class OpacityTransition : ValueTransition
{
    this(int timeMs, bool isCycle = false, bool isInverse = true, Interpolator interpolator = null)
    {
        super(0.0, 1.0, timeMs, interpolator);

        this.isInverse = isInverse;
        this.isCycle = isCycle;

        onOldNewValue ~= (oldValue, value) {
            onObjects((object) { object.opacity = value; });
        };
    }
}
