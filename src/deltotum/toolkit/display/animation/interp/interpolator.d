module deltotum.toolkit.display.animation.interp.interpolator;

import deltotum.maths.vector2d : Vector2d;

/**
 * Authors: initkfs
 */
abstract class Interpolator
{
    abstract double interpolate(double progress0to1);
}