module deltotum.math.math_util;

/**
 * Authors: initkfs
 */
class MathUtil
{

    //the a value and the b value should not change during the interpolation.
    static double lerp(double start, double end, double t)
    {
        return start + (end - start) * clamp1(t);
    }

    static double clamp1(double value)
    {
        //TODO compare double
        if (value < 0)
        {
            return 0;
        }
        else if (value > 1)
        {
            return 1;
        }
        else
        {
            return value;
        }
    }
}
