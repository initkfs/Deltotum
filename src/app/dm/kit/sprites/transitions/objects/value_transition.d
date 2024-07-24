module app.dm.kit.sprites.transitions.objects.value_transition;

import app.dm.math.interps.interpolator : Interpolator;
import app.dm.kit.sprites.transitions.objects.object_transition : ObjectTransition;

/**
 * Authors: initkfs
 */
class ValueTransition : ObjectTransition!double
{
    this(double minValue = 0, double maxValue = 1, int timeMs = 200, Interpolator interpolator = null)
    {
        super(minValue, maxValue, timeMs, interpolator);
    }
}
