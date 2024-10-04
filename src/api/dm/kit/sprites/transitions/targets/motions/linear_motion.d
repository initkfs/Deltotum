module api.dm.kit.sprites.transitions.targets.motions.linear_motion;

import api.dm.kit.sprites.transitions.targets.target_transition : TargetTransition;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.sprites.transitions.curves.interpolator : Interpolator;
import api.math.vec2 : Vec2d;

/**
 * Authors: initkfs
 */
class LinearMotion : TargetTransition!(Vec2d, Sprite)
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
