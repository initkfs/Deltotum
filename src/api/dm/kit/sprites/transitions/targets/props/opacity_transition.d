module api.dm.kit.sprites.transitions.targets.props.opacity_transition;

import api.dm.kit.sprites.transitions.targets.value_transition : ValueTransition;
import api.dm.kit.sprites.transitions.curves.interpolator : Interpolator;

/**
 * Authors: initkfs
 */
class OpacityTransition : ValueTransition
{
    this(int timeMs = 200, bool isInfinite = false, bool isReverse = false, Interpolator interpolator = null)
    {
        super(0.0, 1.0, timeMs, interpolator);

        this.isReverse = isReverse;
        this.isInfinite = isInfinite;

        onOldNewValue ~= (oldValue, value) {
            onTargetsIsContinue((object) { object.opacity = value; return true; });
        };
    }
}
