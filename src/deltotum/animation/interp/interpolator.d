module deltotum.animation.interp.interpolator;

import deltotum.math.vector2d : Vector2d;

/**
 * Authors: initkfs
 */
abstract class Interpolator
{
    abstract double interpolate(double progress0to1);
}
