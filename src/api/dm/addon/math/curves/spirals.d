module api.dm.addon.math.curves.spirals;

import api.dm.addon.math.curves.curve_maker : CurveMaker;
import api.dm.math.vector2 : Vector2;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class Spirals : CurveMaker
{
    Vector2[] archimedean(double innerRadius, double growthRate, size_t turnCount = 1, double step = 0.2)
    {
        Vector2[] result;
        pointsIteration(step, 0, Math.PI * 2 * turnCount, (double angleRad) {
            const polarR = innerRadius + growthRate * angleRad;
            result ~= Vector2.fromPolarRad(angleRad, polarR);
            return true;
        });

        return result;
    }

     Vector2[] lituus(double k, size_t turnCount = 1, double scale = 1.0, double step = 0.2)
    {
        assert(k != 0);

        Vector2[] result;
        pointsIteration(step, step, Math.PI * 2 * turnCount, (double angleRad) {
            const polarR = k / (Math.sqrt(angleRad)) * scale;
            result ~= Vector2.fromPolarRad(angleRad, polarR);
            return true;
        });

        return result;
    }

    Vector2[] cochleoid(double a, size_t turnCount = 1, double scale = 1.0, double step = 0.2)
    {
        assert(a != 0);

        Vector2[] result;
        pointsIteration(step, step, Math.PI * 2 * turnCount, (double angleRad) {
            const polarR = ((a * Math.sin(angleRad)) / angleRad) * scale;
            result ~= Vector2.fromPolarRad(angleRad, polarR);
            return true;
        });

        return result;
    }
    
}
