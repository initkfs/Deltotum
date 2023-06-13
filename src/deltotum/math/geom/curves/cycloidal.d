module deltotum.math.geom.curves.cycloidal;

import deltotum.math.geom.curves.curve_maker: CurveMaker;
import deltotum.math.vector2d : Vector2d;

import Math = deltotum.math;

/**
 * Authors: initkfs
 */
class Cycloidal : CurveMaker
{

    Vector2d[] hypotrochoid(double radius1, double theta1, double radius2, double theta2, double dots = 500, double scale = 1.0)
    {
        Vector2d[] points;
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
            points ~= Vector2d(x, y);
        }

        return points;
    }

    Vector2d[] cycloid(double radius = 10, size_t dots = 100, double step = 0.5)
    {
        //TODO check is -PI<=theta<=PI
        Vector2d[] result;

        import Math = deltotum.math;

        pointsIteration(step, 0, dots, (dt) {
            const x = (radius * dt) - radius * Math.sin(dt);
            const y = radius - radius * Math.cos(dt);
            result ~= Vector2d(x, y);
            return true;
        });
        return result;
    }

}
