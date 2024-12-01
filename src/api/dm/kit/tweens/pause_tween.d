module api.dm.kit.tweens.pause_tween;

import api.dm.kit.tweens.min_max_tween: MinMaxTween;
import api.dm.kit.tweens.curves.interpolator : Interpolator;

/**
 * Authors: initkfs
 */
class PauseTween : MinMaxTween!double
{
    this(size_t timeMs = 200, Interpolator interpolator = null)
    {
        super(0, 1.0, timeMs, interpolator);
    }
}
