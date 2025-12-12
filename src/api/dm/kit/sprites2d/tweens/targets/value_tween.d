module api.dm.kit.sprites2d.tweens.targets.value_tween;

import api.dm.kit.sprites2d.sprite2d: Sprite2d;
import api.dm.kit.sprites2d.tweens.curves.interpolator : Interpolator;
import api.dm.kit.sprites2d.tweens.targets.target_tween : TargetTween;

/**
 * Authors: initkfs
 */
class ValueTween : TargetTween!(float, Sprite2d)
{
    this(float minValue = 0, float maxValue = 1, int timeMs = 200, Interpolator interpolator = null)
    {
        super(minValue, maxValue, timeMs, interpolator);
    }
}
