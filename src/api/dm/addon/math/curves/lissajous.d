module api.dm.addon.math.curves.lissajous;
import api.math.geom2.vec2 : Vec2d;
import api.dm.addon.math.curves.curve_maker : CurveMaker;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class Lissajous : CurveMaker
{
    Vec2d[] curve(double amplitudeX = 50, double freqX = 1, double amplitudeY = 50, double freqY = 2, double phaseShift = (
            Math.PI / 2), double dots = 2000, double step = 0.01)
    {
        Vec2d[] points;
        curve(amplitudeX, freqX, amplitudeY, freqY, phaseShift, dots, step, (x, y) {
            points ~= Vec2d(x, y);
        });
        return points;
    }

    void curve(double amplitudeX, double freqX, double amplitudeY, double freqY, double phaseShift, double dots, double step, scope void delegate(
            double, double) onPointXY)
    {
        //TODO performance
        // pointsIteration(step, 0, dots, (dt) {
        //     const x = amplitudeX * Math.sin(freqX * dt + phaseShift);
        //     const y = amplitudeY * Math.sin(freqY * dt);
        //     onPointXY(x, y);
        //     return true;
        // });

        double dt = 0;
        foreach (i; 0 .. dots)
        {
            dt += step;
            const x = amplitudeX * Math.sin(freqX * dt + phaseShift);
            const y = amplitudeY * Math.sin(freqY * dt);
            onPointXY(x, y);
        }
    }

}
