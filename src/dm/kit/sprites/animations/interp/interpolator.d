module dm.kit.sprites.animations.interp.interpolator;

import dm.math.vector2d : Vector2d;

/**
 * Authors: initkfs
 */
abstract class Interpolator
{
    abstract double interpolate(double progress0to1);
}
