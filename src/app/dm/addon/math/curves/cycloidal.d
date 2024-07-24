module app.dm.addon.math.curves.cycloidal;

import app.dm.addon.math.curves.curve_maker: CurveMaker;
import app.dm.math.vector2 : Vector2;

import Math = app.dm.math;

/**
 * Authors: initkfs
 */
class Cycloidal : CurveMaker
{

    Vector2[] hypotrochoid(double radius1, double theta1, double radius2, double theta2, double dots = 500, double scale = 1.0)
    {
        Vector2[] points;
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
            points ~= Vector2(x, y);
        }

        return points;
    }

    Vector2[] cycloid(double radius = 10, size_t dots = 100, double step = 0.5)
    {
        //TODO check is -PI<=theta<=PI
        Vector2[] result;

        import Math = app.dm.math;

        pointsIteration(step, 0, dots, (dt) {
            const x = (radius * dt) - radius * Math.sin(dt);
            const y = radius - radius * Math.cos(dt);
            result ~= Vector2(x, y);
            return true;
        });
        return result;
    }

}
