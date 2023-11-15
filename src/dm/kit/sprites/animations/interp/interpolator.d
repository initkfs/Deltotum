module dm.kit.sprites.animations.interp.interpolator;

import dm.math.vector2 : Vector2;

/**
 * Authors: initkfs
 */
abstract class Interpolator
{
    abstract double interpolate(double progress0to1);
}
