module app.dm.addon.math.curves.cubic_plane_curves;

import app.dm.addon.math.curves.curve_maker : CurveMaker;
import app.dm.math.vector2 : Vector2;

import Math = app.dm.math;

/**
 * Authors: initkfs
 */
class CubicPlaneCurves : CurveMaker
{
    Vector2[] trisectrixMaclaurin(double radius = 10, double step = 0.1)
    {
        Vector2[] result;

        import Math = app.dm.math;

        pointsIteration(step, -step, Math.PI * 2, (angle) {
            auto r = (radius / 2) * (4 * Math.cos(angle) - Math.sec(angle));
            result ~= Vector2.fromPolarRad(angle, r);
            return true;
        });
        return result;
    }
}
