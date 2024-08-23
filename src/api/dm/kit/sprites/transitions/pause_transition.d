module api.dm.kit.sprites.transitions.pause_transition;

import api.dm.kit.sprites.transitions.min_max_transition: MinMaxTransition;
import api.math.interps.interpolator : Interpolator;

/**
 * Authors: initkfs
 */
class PauseTransition : MinMaxTransition!double
{
    this(size_t timeMs = 200, Interpolator interpolator = null)
    {
        super(0, 1.0, timeMs, interpolator);
    }
}
