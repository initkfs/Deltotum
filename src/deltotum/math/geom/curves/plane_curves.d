module deltotum.math.geom.curves.plane_curves;

import deltotum.math.geom.curves.curve_maker : CurveMaker;
import deltotum.math.vector2d : Vector2d;

import Math = deltotum.math;

/**
 * Authors: initkfs
 */
class PlaneCurve : CurveMaker
{

    Vector2d[] witchOfAgnesi(double radius = 50, double step = 0.01)
    {
        Vector2d[] result;

        import Math = deltotum.math;

        pointsIteration(step, -(Math.PI / 2) + step, Math.PI / 2 - step, (dt) {
            const x = radius * Math.tan(dt);
            const y = radius * (Math.cos(dt) ^^ 2);
            result ~= Vector2d(x, y);
            return true;
        });
        return result;
    }

    Vector2d[] bicorn(double radius = 50, double thetaRad = 0.01, size_t dots = 500, double step = 1.0)
    {
        //TODO check is -PI<=theta<=PI
        Vector2d[] result;
        import Math = deltotum.math;

        pointsIteration(step, 0, dots, (dt) {
            const x = radius * Math.sin(thetaRad * dt);
            const y = radius * (
                ((Math.cos(thetaRad * dt) ^^ 2) * (2 + Math.cos(thetaRad * dt)))
                /
                (3 + (Math.sin(thetaRad * dt) ^^ 2))
            );
            result ~= Vector2d(x, y);
            return true;
        });
        return result;
    }

    Vector2d[] cardioid(double radius = 10, double step = 0.01)
    {
        //TODO check is -PI<=theta<=PI
        Vector2d[] result;

        import Math = deltotum.math;

        pointsIteration(step, 0, Math.PI * 2, (angle) {
            auto x = (2 * radius) * (1 - Math.cos(angle)) * Math.cos(angle);
            auto y = (2 * radius) * (1 - Math.cos(angle)) * Math.sin(angle);

            result ~= Vector2d(x, y);
            return true;
        });

        return result;
    }

    Vector2d[] lemniscateBernoulli(double distance = 10, double step = 0.01)
    {
        //TODO check is -PI<=theta<=PI
        Vector2d[] result;

        import Math = deltotum.math;
        import StdMath = std.math;

        pointsIteration(step, 0, Math.PI * 2, (angle) {
            auto x = (distance * Math.sqrt(2) * Math.cos(angle)) / (1 + Math.pow(Math.sin(angle), 2));
            auto y = (distance * Math.sqrt(2) * Math.sin(angle) * Math.cos(angle)) / (
                1 + Math.pow(Math.sin(angle), 2));

            result ~= Vector2d(x, y);
            return true;
        });

        return result;
    }

    Vector2d[] strophoid(double phi, double step = 0.01, double scale = 1.0){
        Vector2d[] result;

        pointsIteration(step, 0, Math.PI * 2, (angle){
            const r = - ((phi * Math.cos(2 * angle)) / Math.cos(angle)) * scale;
            result ~= Vector2d.fromPolarRad(angle, r);
            return true;
        });

        return result;
    }

    Vector2d[] foliumOfDescartes(double phi, double step = 0.01, double scale = 1.0){
        Vector2d[] result;

        pointsIteration(step, 0, Math.PI * 2, (angle){
            const r = (3 * phi * Math.cos(angle) * Math.sin(angle)) / ((Math.cos(angle) ^^ 3) + (Math.sin(angle) ^^ 3)) * scale;
            result ~= Vector2d.fromPolarRad(angle, r);
            return true;
        });

        return result;
    }

     Vector2d[] tractrix(double length, double step = 0.01){
        Vector2d[] result;

        import std.math.exponential: log;

        pointsIteration(step, 0, Math.PI, (angle){
            const sign = Math.sign(angle);
            const x = sign * length * ((log(Math.tan(Math.abs(angle / 2)))) + Math.cos(Math.abs(angle)));
            const y = length * Math.sin(angle);
            result ~= Vector2d(x, y);
            return true;
        });

        return result;
    }
}
