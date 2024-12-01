module api.dm.kit.sprites.sprites2d.tweens2.targets.props.opacity_tween;

import api.dm.kit.sprites.sprites2d.tweens2.targets.value_tween : ValueTween;
import api.dm.kit.tweens.curves.interpolator : Interpolator;

/**
 * Authors: initkfs
 */
class OpacityTween : ValueTween
{
    this(int timeMs = 200, double minValue = 0, double maxValue = 1.0, bool isInfinite = false, bool isReverse = false, Interpolator interpolator = null)
    {
        super(minValue, maxValue, timeMs, interpolator);

        this.isReverse = isReverse;
        this.isInfinite = isInfinite;

        onOldNewValue ~= (oldValue, value) {
            onTargetsIsContinue((object) { object.opacity = value; return true; });
        };
    }
}
