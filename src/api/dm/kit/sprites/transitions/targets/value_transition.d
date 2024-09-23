module api.dm.kit.sprites.transitions.targets.value_transition;

import api.dm.kit.sprites.sprite: Sprite;
import api.dm.kit.sprites.transitions.curves.interpolator : Interpolator;
import api.dm.kit.sprites.transitions.targets.target_transition : TargetTransition;

/**
 * Authors: initkfs
 */
class ValueTransition : TargetTransition!(double, Sprite)
{
    this(double minValue = 0, double maxValue = 1, int timeMs = 200, Interpolator interpolator = null)
    {
        super(minValue, maxValue, timeMs, interpolator);
    }
}
