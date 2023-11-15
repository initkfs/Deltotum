module dm.kit.sprites.animations.object.motion.linear_motion_transition;

import dm.kit.sprites.animations.object.display_object_transition : DisplayObjectTransition;
import dm.kit.sprites.sprite : Sprite;
import dm.kit.sprites.animations.interp.interpolator : Interpolator;
import dm.math.vector2d : Vector2d;

/**
 * Authors: initkfs
 */
class LinearMotionTransition : DisplayObjectTransition!Vector2d
{
    this(Sprite obj, Vector2d start, Vector2d end, int timeMs = 200, Interpolator interpolator = null)
    {
        super(obj, start, end, timeMs, interpolator);
        onValue = (value)
        {
            displayObject.x = value.x;
            displayObject.y = value.y;
        };
    }
}
