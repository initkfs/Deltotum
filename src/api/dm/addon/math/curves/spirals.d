module api.dm.addon.math.curves.spirals;

import api.dm.addon.math.curves.curve_maker : CurveMaker;
import api.math.geom2.vec2 : Vec2d;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class Spirals : CurveMaker
{
    Vec2d[] archimedean(double innerRadius, double growthRate, size_t turnCount = 1, double step = 0.2)
    {
        Vec2d[] result;
        pointsIteration(step, 0, Math.PI * 2 * turnCount, (double angleRad) {
            const polarR = innerRadius + growthRate * angleRad;
            result ~= Vec2d.fromPolarRad(angleRad, polarR);
            return true;
        });

        return result;
    }

     Vec2d[] lituus(double k, size_t turnCount = 1, double scale = 1.0, double step = 0.2)
    {
        assert(k != 0);

        Vec2d[] result;
        pointsIteration(step, step, Math.PI * 2 * turnCount, (double angleRad) {
            const polarR = k / (Math.sqrt(angleRad)) * scale;
            result ~= Vec2d.fromPolarRad(angleRad, polarR);
            return true;
        });

        return result;
    }

    Vec2d[] cochleoid(double a, size_t turnCount = 1, double scale = 1.0, double step = 0.2)
    {
        assert(a != 0);

        Vec2d[] result;
        pointsIteration(step, step, Math.PI * 2 * turnCount, (double angleRad) {
            const polarR = ((a * Math.sin(angleRad)) / angleRad) * scale;
            result ~= Vec2d.fromPolarRad(angleRad, polarR);
            return true;
        });

        return result;
    }
    
}
