module deltotum.tweens.interp.linear;

import deltotum.tweens.interp.interpolator : Interpolator;
import deltotum.math.math_util : MathUtil;

/**
 * Authors: initkfs
 */
class Linear : Interpolator
{

    override double interpolate(double start, double end, double value)
    {
        return MathUtil.lerp(start, end, value);
    }
}
