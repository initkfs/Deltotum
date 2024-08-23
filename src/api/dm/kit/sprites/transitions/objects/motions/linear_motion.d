module api.dm.kit.sprites.transitions.objects.motions.linear_motion;

import api.dm.kit.sprites.transitions.objects.object_transition : ObjectTransition;
import api.dm.math.interps.interpolator : Interpolator;
import api.dm.math.vector2 : Vector2;

/**
 * Authors: initkfs
 */
class LinearMotion : ObjectTransition!Vector2
{
    this(Vector2 start, Vector2 end, int timeMs = 200, Interpolator interpolator = null)
    {
        super(start, end, timeMs, interpolator);
        onOldNewValue ~= (oldValue, value) {
            onObjects((object) { object.x = value.x; object.y = value.y; });
        };
    }
}
