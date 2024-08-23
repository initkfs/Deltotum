module api.dm.math.interps.interpolator;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
abstract class Interpolator
{
    double function(double) interpolateMethod;

    invariant
    {
        assert(interpolateMethod, "Interpolate method must not be null");
    }

    double interpolate(double progress0to1)
    {
        const double progress = Math.clamp01(progress0to1);
        const double interpProgress = interpolateMethod(progress);
        return interpProgress;
    }
}
