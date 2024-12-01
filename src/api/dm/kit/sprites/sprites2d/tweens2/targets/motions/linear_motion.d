module api.dm.kit.sprites.sprites2d.tweens2.targets.motions.linear_motion;

import api.dm.kit.sprites.sprites2d.tweens2.targets.target_tween : TargetTween;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.tweens.curves.interpolator : Interpolator;
import api.math.geom2.vec2 : Vec2d;

/**
 * Authors: initkfs
 */
class LinearMotion : TargetTween!(Vec2d, Sprite2d)
{
    this(Vec2d start, Vec2d end, int timeMs = 200, Interpolator interpolator = null)
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
