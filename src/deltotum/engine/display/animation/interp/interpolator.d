module deltotum.engine.display.animation.interp.interpolator;

import deltotum.core.math.vector2d : Vector2d;

/**
 * Authors: initkfs
 */
abstract class Interpolator
{
    abstract double interpolate(double progress0to1);
}
