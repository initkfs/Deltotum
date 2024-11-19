module api.dm.kit.sprites.tweens.targets.motions.linear_motion;

import api.dm.kit.sprites.tweens.targets.target_tween : TargetTween;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.sprites.tweens.curves.interpolator : Interpolator;
import api.math.geom2.vec2 : Vec2d;

/**
 * Authors: initkfs
 */
class LinearMotion : TargetTween!(Vec2d, Sprite)
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
