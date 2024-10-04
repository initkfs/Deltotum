module api.dm.kit.sprites.transitions.targets.motions.circular_motion;

import api.dm.kit.sprites.transitions.targets.value_transition : ValueTransition;
import api.dm.kit.sprites.transitions.curves.interpolator : Interpolator;
import api.math.vec2 : Vec2d;
import math = api.dm.math;

/**
 * Authors: initkfs
 */
class CircularMotion : ValueTransition
{
    Vec2d center;
    double radius = 0;

    void delegate(Vec2d) onPoint;

    this(Vec2d center = Vec2d(0, 0), double radius = 100, int timeMs = 200, Interpolator interpolator = null)
    {
        super(0, 360, timeMs, interpolator);

        this.radius = radius;
        this.center = center;

        onOldNewValue ~= (oldValue, value) {
            const x = center.x + math.cosDeg(value) * radius;
            const y = center.y + math.sinDeg(value) * radius;

            onTargetsIsContinue((object) { object.xy(x, y); return true; });

            if (onPoint)
            {
                onPoint(Vec2d(x, y));
            }
        };
    }
}
