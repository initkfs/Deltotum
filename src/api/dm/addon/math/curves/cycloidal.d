module api.dm.addon.math.curves.cycloidal;

import api.dm.addon.math.curves.curve_maker: CurveMaker;
import api.math.vec2 : Vec2d;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class Cycloidal : CurveMaker
{

    Vec2d[] hypotrochoid(double radius1, double theta1, double radius2, double theta2, double dots = 500, double scale = 1.0)
    {
        Vec2d[] points;
        auto initTheta = Math.PI * 2 / dots;
        double theta = 0;

        foreach (i; 0 .. dots)
        {
            theta = i * initTheta;
            const x = (radius1 * Math.cos(
                    theta1 * theta) + radius2 * Math.cos(
                    theta2 * theta)) * scale;
            const y = (radius1 * Math.sin(
                    theta1 * theta) - radius2 * Math.sin(
                    theta2 * theta)) * scale;
            points ~= Vec2d(x, y);
        }

        return points;
    }

    Vec2d[] cycloid(double radius = 10, size_t dots = 100, double step = 0.5)
    {
        //TODO check is -PI<=theta<=PI
        Vec2d[] result;

        import Math = api.dm.math;

        pointsIteration(step, 0, dots, (dt) {
            const x = (radius * dt) - radius * Math.sin(dt);
            const y = radius - radius * Math.cos(dt);
            result ~= Vec2d(x, y);
            return true;
        });
        return result;
    }

}
