module dm.addon.math.curves.lissajous;
import dm.math.vector2 : Vector2;
import dm.addon.math.curves.curve_maker : CurveMaker;

import Math = dm.math;

/**
 * Authors: initkfs
 */
class Lissajous : CurveMaker
{
    Vector2[] curve(double amplitudeX = 50, double freqX = 1, double amplitudeY = 50, double freqY = 2, double phaseShift = (
            Math.PI / 2), double dots = 2000, double step = 0.01)
    {
        Vector2[] points;
        curve(amplitudeX, freqX, amplitudeY, freqY, phaseShift, dots, step, (x, y) {
            points ~= Vector2(x, y);
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
