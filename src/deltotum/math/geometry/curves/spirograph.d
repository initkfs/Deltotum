module deltotum.math.geometry.curves.spirograph;
import deltotum.math.vector2d : Vector2d;

import Math = deltotum.math;

/**
 * Authors: initkfs
 */
class Spirograph
{
    Vector2d[] hypotrochoidPoints(double radius1, double theta1, double radius2, double theta2, double dots = 2000, double scale = 1)
    {
        Vector2d[] points;
        hypotrochoid(radius1, theta1, radius2, theta2, dots, scale, (x, y) {
            points ~= Vector2d(x, y);
        });
        return points;
    }

    void hypotrochoid(double radius1, double theta1, double radius2, double theta2, double dots, double scale, scope void delegate(
            double, double) onPointXY)
    {
        auto initTheta = Math.PI * 2 / dots;
        double theta = 0;

        foreach (i; 0 .. dots + 1)
        {
            theta = i * initTheta;
            const x = (radius1 * Math.cos(
                    theta1 * theta) + radius2 * Math.cos(
                    theta2 * theta)) * scale;
            const y = (radius1 * Math.sin(
                    theta1 * theta) - radius2 * Math.sin(
                    theta2 * theta)) * scale;
            onPointXY(x, y);
        }
    }

}
