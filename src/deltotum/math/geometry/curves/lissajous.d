module deltotum.math.geometry.curves.lissajous;
import deltotum.math.vector2d : Vector2d;

import Math = deltotum.math;

/**
 * Authors: initkfs
 */
class Lissajous
{
    Vector2d[] curve(double amplitudeX = 50, double freqX = 1, double amplitudeY = 50, double freqY = 2, double dots = 2000, double phaseShift = (Math.PI / 2), double step = 0.01)
    {
        Vector2d[] points;
        curve(amplitudeX, freqX, amplitudeY, freqY, dots, phaseShift, step, (x, y) {
            points ~= Vector2d(x, y);
        });
        return points;
    }

    void curve(double amplitudeX, double freqX, double amplitudeY, double freqY, double dots, double phaseShift, double step, scope void delegate(
            double, double) onPointXY)
    {
        double dt = 0;
        foreach (i; 0 .. dots + 1)
        {
            dt+=step;
            auto x = amplitudeX * Math.sin(freqX*dt + phaseShift); 
            auto y = amplitudeY * Math.sin(freqY*dt); 
            onPointXY(x, y);
        }
    }

}
