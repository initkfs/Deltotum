module dm.kit.sprites.transitions.pause_transition;

import dm.kit.sprites.transitions.min_max_transition: MinMaxTransition;
import dm.math.interps.interpolator : Interpolator;

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
