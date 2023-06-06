module deltotum.math.geometry.curves.cubic_plane_curves;

import deltotum.math.geometry.curves.curve_maker : CurveMaker;
import deltotum.math.vector2d : Vector2d;

import Math = deltotum.math;

/**
 * Authors: initkfs
 */
class CubicPlaneCurves : CurveMaker
{
    Vector2d[] trisectrixMaclaurin(double radius = 10, double step = 0.1)
    {
        Vector2d[] result;

        import Math = deltotum.math;

        pointsIteration(step, -step, Math.PI * 2, (angle) {
            auto r = (radius / 2) * (4 * Math.cos(angle) - Math.sec(angle));
            result ~= Vector2d.fromPolarRad(angle, r);
            return true;
        });
        return result;
    }
}
