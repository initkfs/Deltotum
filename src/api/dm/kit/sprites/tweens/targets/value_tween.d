module api.dm.kit.sprites.tweens.targets.value_tween;

import api.dm.kit.sprites.sprite: Sprite;
import api.dm.kit.sprites.tweens.curves.interpolator : Interpolator;
import api.dm.kit.sprites.tweens.targets.target_tween : TargetTween;

/**
 * Authors: initkfs
 */
class ValueTween : TargetTween!(double, Sprite)
{
    this(double minValue = 0, double maxValue = 1, int timeMs = 200, Interpolator interpolator = null)
    {
        super(minValue, maxValue, timeMs, interpolator);
    }
}
