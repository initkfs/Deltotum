module api.dm.kit.sprites2d.tweens.targets.motions.circular_motion2d;

import api.dm.kit.sprites2d.tweens.targets.value_tween2d : ValueTween2d;
import api.dm.kit.tweens.curves.interpolator : Interpolator;
import api.math.geom2.vec2 : Vec2f;
import math = api.dm.math;

/**
 * Authors: initkfs
 */
class CircularMotion2d : ValueTween2d
{
    Vec2f center;
    float radius = 0;

    void delegate(Vec2f) onPoint;

    this(Vec2f center = Vec2f(0, 0), float radius = 100, int timeMs = 200, Interpolator interpolator = null)
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
                onPoint(Vec2f(x, y));
            }
        };
    }
}
