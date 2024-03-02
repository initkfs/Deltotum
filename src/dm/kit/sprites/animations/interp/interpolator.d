module dm.kit.sprites.animations.interp.interpolator;

import Math = dm.math;

/**
 * Authors: initkfs
 */
abstract class Interpolator
{
    double function(double) interpolateMethod;

    double interpolate(double progress0to1)
    {
        if (!interpolateMethod)
        {
            return 0;
        }

        const double progress = Math.clamp01(progress0to1);
        const double interpProgress = interpolateMethod(progress);
        return interpProgress;
    }
}
