module api.dm.kit.sprites.sprites2d.tweens2.targets.props.angle_tween;

import api.dm.kit.sprites.sprites2d.tweens2.targets.value_tween : ValueTween;
import api.dm.kit.tweens.curves.interpolator : Interpolator;

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
