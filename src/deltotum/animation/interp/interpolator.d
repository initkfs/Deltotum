module deltotum.animation.interp.interpolator;

/**
 * Authors: initkfs
 */
abstract class Interpolator
{
    abstract double interpolate(double start, double end, double progress0to1);
}
