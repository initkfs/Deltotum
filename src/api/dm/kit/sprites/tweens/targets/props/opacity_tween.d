module api.dm.kit.sprites.tweens.targets.props.opacity_tween;

import api.dm.kit.sprites.tweens.targets.value_tween : ValueTween;
import api.dm.kit.sprites.tweens.curves.interpolator : Interpolator;

/**
 * Authors: initkfs
 */
class OpacityTween : ValueTween
{
    this(int timeMs = 200, bool isInfinite = false, bool isReverse = false, Interpolator interpolator = null)
    {
        super(0.0, 1.0, timeMs, interpolator);

        this.isReverse = isReverse;
        this.isInfinite = isInfinite;

        onOldNewValue ~= (oldValue, value) {
            onTargetsIsContinue((object) { object.opacity = value; return true; });
        };
    }
}
