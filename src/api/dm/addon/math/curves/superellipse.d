module api.dm.addon.math.curves.superellipse;

import api.dm.addon.math.curves.curve_maker : CurveMaker;
import api.math.geom2.vec2 : Vec2d;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class Superellipse : CurveMaker
{

    Vec2d[] superformula(double a, double b, double m, double n1, double n2, double n3, double scale = 1.0, double step = 0.01)
    {
        Vec2d[] result;
        pointsIteration(step, 0, Math.PI * 2, (angle) {
            auto x = Math.pow(Math.abs(Math.cos(m * angle / 4) / a), n2);
            auto y = Math.pow(Math.abs(Math.sin(m * angle / 4) / b), n3);
            auto r = Math.pow(x + y, -1 / n1);

            result ~= Vec2d.fromPolarRad(angle, r * scale);
            return true;
        });

        return result;
    }

    Vec2d[] superellipse(double a, double b, double n, double scale = 1.0, double step = 0.1)
    {
        Vec2d[] result;

        pointsIteration(step, 0, 1000, (angle) {
            const cosAngle = Math.cos(angle);
            const sinAngle = Math.sin(angle);
            auto x = a * (Math.abs(cosAngle) ^^ (2 / n)) * scale * Math.sign(cosAngle);
            auto y = b * (Math.abs(sinAngle) ^^ (2 / n)) * scale * Math.sign(sinAngle);

            result ~= Vec2d(x, y);
            return true;
        });

        return result;
    }

     Vec2d[] squircle(double scale = 1.0, double step = 0.1)
    {
        return superellipse(1, 1, 4, scale, step);
    }

}
