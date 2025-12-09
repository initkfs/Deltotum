module api.dm.kit.tweens.curves.interpolator;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
abstract class Interpolator
{
    float function(float) interpolateMethod;

    invariant
    {
        assert(interpolateMethod, "Interpolate method must not be null");
    }

    float interpolate(float progress0to1)
    {
        const float progress = Math.clamp01(progress0to1);
        const float interpProgress = interpolateMethod(progress);
        return interpProgress;
    }
}
