module api.dm.kit.sprites.transitions.targets.motions.linear_motion;

import api.dm.kit.sprites.transitions.targets.target_transition : TargetTransition;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.sprites.transitions.curves.interpolator : Interpolator;
import api.math.vector2 : Vector2;

/**
 * Authors: initkfs
 */
class LinearMotion : TargetTransition!(Vector2, Sprite)
{
    this(Vector2 start, Vector2 end, int timeMs = 200, Interpolator interpolator = null)
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
