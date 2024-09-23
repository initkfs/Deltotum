module api.dm.kit.sprites.transitions.targets.props.angle_transition;

import api.dm.kit.sprites.transitions.targets.value_transition : ValueTransition;
import api.dm.kit.sprites.transitions.curves.interpolator : Interpolator;

/**
 * Authors: initkfs
 */
class AngleTransition : ValueTransition
{
    this(int timeMs, Interpolator interpolator = null)
    {
        super(0, 360, timeMs, interpolator);
        onOldNewValue ~= (oldValue, value) {
            onTargetsIsContinue((object) { object.angle = value; return true; });
        };
    }
}
