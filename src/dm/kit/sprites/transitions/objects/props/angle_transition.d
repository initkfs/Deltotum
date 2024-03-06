module dm.kit.sprites.transitions.objects.props.angle_transition;

import dm.kit.sprites.transitions.objects.value_transition : ValueTransition;
import dm.math.interps.interpolator : Interpolator;

/**
 * Authors: initkfs
 */
class AngleTransition : ValueTransition
{
    this(int timeMs, Interpolator interpolator = null)
    {
        super(0, 360, timeMs, interpolator);
        onValue ~= (value) {
            onObjects((object) { object.angle = value; });
        };
    }
}
