module dm.kit.sprites.animations.object.motion.linear_motion_transition;

import dm.kit.sprites.animations.object.display_object_transition : DisplayObjectTransition;
import dm.kit.sprites.sprite : Sprite;
import dm.kit.sprites.animations.interp.interpolator : Interpolator;
import dm.math.vector2 : Vector2;

/**
 * Authors: initkfs
 */
class LinearMotionTransition : DisplayObjectTransition!Vector2
{
    this(Sprite obj, Vector2 start, Vector2 end, int timeMs = 200, Interpolator interpolator = null)
    {
        super(obj, start, end, timeMs, interpolator);
        onValue = (value)
        {
            displayObject.x = value.x;
            displayObject.y = value.y;
        };
    }
}
