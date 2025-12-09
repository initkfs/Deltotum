module api.dm.kit.sprites2d.tweens.targets.motions.linear_motion2d;

import api.dm.kit.sprites2d.tweens.targets.target_tween2d : TargetTween2d;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.tweens.curves.interpolator : Interpolator;
import api.math.geom2.vec2 : Vec2f;

/**
 * Authors: initkfs
 */
class LinearMotion2d : TargetTween2d!(Vec2f, Sprite2d)
{
    this(Vec2f start, Vec2f end, int timeMs = 200, Interpolator interpolator = null)
    {
        super(start, end, timeMs, interpolator);
        onOldNewValue ~= (oldValue, value) {
            onTargetsIsContinue((object) {
                object.x = value.x;
                object.y = value.y;
                return true;
            });
        };
    }
}
