module api.dm.addon.procedural.fractals.images.mandelbrot;

import api.dm.addon.procedural.fractals.images.complex_fractal_image : ComplexFractalImage;

import Math = api.dm.math;

import api.dm.kit.graphics.colors.rgba : RGBA;

import std.complex;

/**
 * Authors: initkfs
 */
class Mandelbrot : ComplexFractalImage
{
    RGBA backgroundColor = RGBA.black;
    RGBA foregroundColor = RGBA.white;

    this(double width = 100, double height = 100, double scaleFactor = 0.03, size_t iterations = 500)
    {
        super(width, height);
        this.scaleFactor = scaleFactor;
        this.iterations = iterations;
    }

    override RGBA calcColor(double x, double y)
    {
        Complex!double c = Complex!double(x, y);

        size_t iterationCount = 0;
        Complex!double z = 0;
        do
        {
            z = z * z + c;
            iterationCount++;
        }
        while (iterationCount < iterations && z.abs < 2.0);

        //or iter step? iter/max
        if(iterationCount == iterations){
            return foregroundColor;
        }

        return backgroundColor;
    }
}
