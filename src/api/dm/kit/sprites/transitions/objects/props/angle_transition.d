module api.dm.kit.sprites.transitions.objects.props.angle_transition;

import api.dm.kit.sprites.transitions.objects.value_transition : ValueTransition;
import api.math.interps.interpolator : Interpolator;

/**
 * Authors: initkfs
 */
class AngleTransition : ValueTransition
{
    this(int timeMs, Interpolator interpolator = null)
    {
        super(0, 360, timeMs, interpolator);
        onOldNewValue ~= (oldValue, value) {
            onObjects((object) { object.angle = value; });
        };
    }
}
