module deltotum.math.geom.curves.roses;

import deltotum.math.geom.curves.curve_maker : CurveMaker;
import deltotum.math.vector2d : Vector2d;

import Math = deltotum.math;

/**
 * Authors: initkfs
 */
class Roses : CurveMaker
{

    Vector2d[] rose(double roseSize, double n, double d, size_t curlsCount = 1, double step = 0.01)
    {
        Vector2d[] result;

        const petalsFactor = n / d;

        //For an integer k, the number of petals is k if k is odd and 2k if even
        pointsIteration(step, 0, Math.PI * 2 * curlsCount - step, (angle) {
            auto r = roseSize * Math.sin(petalsFactor * angle);
            result ~= Vector2d.fromPolarRad(angle, r);
            return true;
        });
        return result;
    }

}
