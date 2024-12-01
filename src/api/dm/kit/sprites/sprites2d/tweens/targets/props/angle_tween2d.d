module api.dm.kit.sprites.sprites2d.tweens.targets.props.angle_tween2d;

import api.dm.kit.sprites.sprites2d.tweens.targets.value_tween2d : ValueTween2d;
import api.dm.kit.tweens.curves.interpolator : Interpolator;

/**
 * Authors: initkfs
 */
class AngleTween2d : ValueTween2d
{
    this(int timeMs, Interpolator interpolator = null)
    {
        super(0, 360, timeMs, interpolator);
        onOldNewValue ~= (oldValue, value) {
            onTargetsIsContinue((object) { object.angle = value; return true; });
        };
    }
}
