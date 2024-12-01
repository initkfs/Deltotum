module api.dm.kit.sprites.sprites2d.tweens.pause_tween2d;

import api.dm.kit.sprites.sprites2d.tweens.min_max_tween2d: MinMaxTween2d;
import api.dm.kit.tweens.curves.interpolator : Interpolator;

/**
 * Authors: initkfs
 */
class PauseTween2d : MinMaxTween2d!double
{
    this(size_t timeMs = 200, Interpolator interpolator = null)
    {
        super(0, 1.0, timeMs, interpolator);
    }
}
