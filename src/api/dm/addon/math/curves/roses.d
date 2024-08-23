module api.dm.addon.math.curves.roses;

import api.dm.addon.math.curves.curve_maker : CurveMaker;
import api.dm.math.vector2 : Vector2;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class Roses : CurveMaker
{

    Vector2[] rose(double roseSize, double n, double d, size_t curlsCount = 1, double step = 0.01)
    {
        Vector2[] result;

        const petalsFactor = n / d;

        //For an integer k, the number of petals is k if k is odd and 2k if even
        pointsIteration(step, 0, Math.PI * curlsCount - step, (angle) {
            auto r = roseSize * Math.sin(petalsFactor * angle);
            result ~= Vector2.fromPolarRad(angle, r);
            return true;
        });
        return result;
    }

}
