module api.dm.kit.sprites2d.tweens.targets.props.opacity_tween2d;

import api.dm.kit.sprites2d.tweens.targets.value_tween2d : ValueTween2d;
import api.dm.kit.tweens.curves.interpolator : Interpolator;

/**
 * Authors: initkfs
 */
class OpacityTween2d : ValueTween2d
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
