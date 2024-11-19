module api.dm.kit.sprites.tweens.targets.props.angle_tween;

import api.dm.kit.sprites.tweens.targets.value_tween : ValueTween;
import api.dm.kit.sprites.tweens.curves.interpolator : Interpolator;

/**
 * Authors: initkfs
 */
class AngleTween : ValueTween
{
    this(int timeMs, Interpolator interpolator = null)
    {
        super(0, 360, timeMs, interpolator);
        onOldNewValue ~= (oldValue, value) {
            onTargetsIsContinue((object) { object.angle = value; return true; });
        };
    }
}
