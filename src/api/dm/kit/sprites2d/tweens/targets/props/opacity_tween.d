module api.dm.kit.sprites2d.tweens.targets.props.opacity_tween;

import api.dm.kit.sprites2d.tweens.targets.value_tween : ValueTween;
import api.dm.kit.sprites2d.tweens.curves.interpolator : Interpolator;

/**
 * Authors: initkfs
 */
class OpacityTween : ValueTween
{
    this(int timeMs = 200, float minValue = 0, float maxValue = 1.0, bool isInfinite = false, bool isReverse = false, Interpolator interpolator = null)
    {
        super(minValue, maxValue, timeMs, interpolator);

        this.isReverse = isReverse;
        this.isInfinite = isInfinite;

        onOldNewValue ~= (oldValue, value) {
            onTargetsIsContinue((object) { object.opacity = value; return true; });
        };
    }
}
