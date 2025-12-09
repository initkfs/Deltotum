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

    this(float width = 100, float height = 100, float scaleFactor = 0.03, size_t iterations = 500)
    {
        super(width, height);
        this.scaleFactor = scaleFactor;
        this.iterations = iterations;
    }

    override RGBA calcColor(float x, float y)
    {
        Complex!float c = Complex!float(x, y);

        size_t iterationCount = 0;
        Complex!float z = 0;
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
