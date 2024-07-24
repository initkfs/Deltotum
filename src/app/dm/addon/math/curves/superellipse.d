module app.dm.addon.math.curves.superellipse;

import app.dm.addon.math.curves.curve_maker : CurveMaker;
import app.dm.math.vector2 : Vector2;

import Math = app.dm.math;

/**
 * Authors: initkfs
 */
class Superellipse : CurveMaker
{

    Vector2[] superformula(double a, double b, double m, double n1, double n2, double n3, double scale = 1.0, double step = 0.01)
    {
        Vector2[] result;
        pointsIteration(step, 0, Math.PI * 2, (angle) {
            auto x = Math.pow(Math.abs(Math.cos(m * angle / 4) / a), n2);
            auto y = Math.pow(Math.abs(Math.sin(m * angle / 4) / b), n3);
            auto r = Math.pow(x + y, -1 / n1);

            result ~= Vector2.fromPolarRad(angle, r * scale);
            return true;
        });

        return result;
    }

    Vector2[] superellipse(double a, double b, double n, double scale = 1.0, double step = 0.1)
    {
        Vector2[] result;

        pointsIteration(step, 0, 1000, (angle) {
            const cosAngle = Math.cos(angle);
            const sinAngle = Math.sin(angle);
            auto x = a * (Math.abs(cosAngle) ^^ (2 / n)) * scale * Math.sign(cosAngle);
            auto y = b * (Math.abs(sinAngle) ^^ (2 / n)) * scale * Math.sign(sinAngle);

            result ~= Vector2(x, y);
            return true;
        });

        return result;
    }

     Vector2[] squircle(double scale = 1.0, double step = 0.1)
    {
        return superellipse(1, 1, 4, scale, step);
    }

}
