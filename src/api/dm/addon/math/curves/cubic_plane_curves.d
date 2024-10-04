module api.dm.addon.math.curves.cubic_plane_curves;

import api.dm.addon.math.curves.curve_maker : CurveMaker;
import api.math.geom2.vec2 : Vec2d;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class CubicPlaneCurves : CurveMaker
{
    Vec2d[] trisectrixMaclaurin(double radius = 10, double step = 0.1)
    {
        Vec2d[] result;

        import Math = api.dm.math;

        pointsIteration(step, -step, Math.PI * 2, (angle) {
            auto r = (radius / 2) * (4 * Math.cos(angle) - Math.sec(angle));
            result ~= Vec2d.fromPolarRad(angle, r);
            return true;
        });
        return result;
    }
}
