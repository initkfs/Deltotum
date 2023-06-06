module deltotum.math.geometry.curves.spirals;

import deltotum.math.geometry.curves.curve_maker : CurveMaker;
import deltotum.math.vector2d : Vector2d;

import Math = deltotum.math;

/**
 * Authors: initkfs
 */
class Spirals : CurveMaker
{
    Vector2d[] archimedean(double innerRadius, double growthRate, size_t turnCount = 1, double step = 0.2)
    {
        Vector2d[] result;
        pointsIteration(step, 0, Math.PI * 2 * turnCount, (double angleRad) {
            const polarR = innerRadius + growthRate * angleRad;
            result ~= Vector2d.fromPolarRad(angleRad, polarR);
            return true;
        });

        return result;
    }

     Vector2d[] lituus(double k, size_t turnCount = 1, double scale = 1.0, double step = 0.2)
    {
        assert(k != 0);

        Vector2d[] result;
        pointsIteration(step, step, Math.PI * 2 * turnCount, (double angleRad) {
            const polarR = k / (Math.sqrt(angleRad)) * scale;
            result ~= Vector2d.fromPolarRad(angleRad, polarR);
            return true;
        });

        return result;
    }

    Vector2d[] cochleoid(double a, size_t turnCount = 1, double scale = 1.0, double step = 0.2)
    {
        assert(a != 0);

        Vector2d[] result;
        pointsIteration(step, step, Math.PI * 2 * turnCount, (double angleRad) {
            const polarR = ((a * Math.sin(angleRad)) / angleRad) * scale;
            result ~= Vector2d.fromPolarRad(angleRad, polarR);
            return true;
        });

        return result;
    }
    
}
