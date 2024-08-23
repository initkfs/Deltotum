module api.dm.kit.sprites.transitions.objects.motions.circular_motion;

import api.dm.kit.sprites.transitions.objects.value_transition : ValueTransition;
import api.math.interps.interpolator : Interpolator;
import api.math.vector2 : Vector2;
import math = api.dm.math;

/**
 * Authors: initkfs
 */
class CircularMotion : ValueTransition
{
    Vector2 center;
    double radius = 0;

    void delegate(Vector2) onPoint;

    this(Vector2 center = Vector2(0, 0), double radius = 100, int timeMs = 200, Interpolator interpolator = null)
    {
        super(0, 360, timeMs, interpolator);

        this.radius = radius;
        this.center = center;

        onOldNewValue ~= (oldValue, value) {
            const x = center.x + math.cosDeg(value) * radius;
            const y = center.y + math.sinDeg(value) * radius;

            onObjects((object) { object.xy(x, y); });

            if (onPoint)
            {
                onPoint(Vector2(x, y));
            }
        };
    }
}
