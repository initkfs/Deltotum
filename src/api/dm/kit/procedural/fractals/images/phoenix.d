module api.dm.kit.procedural.fractals.images.phoenix;

import api.dm.kit.procedural.fractals.images.complex_fractal_image : ComplexFractalImage;
import api.dm.kit.graphics.colors.rgba : RGBA;

import Math = api.dm.math;

import std.complex;

/**
 * Authors: initkfs
 */
class Phoenix : ComplexFractalImage
{
    alias ComplexF = Complex!float;

    private
    {
        ComplexF coeffC = ComplexF(0.5667, 0.0);
        ComplexF coeffP = ComplexF(-0.5, 0.0);
    }

    this(float width = 100, float height = 100, float scaleFactor = 2.0, size_t iterations = 100)
    {
        super(width, height, scaleFactor, iterations);
    }

    override void drawInCoords(float centerX, float centerY, size_t w, size_t h)
    {
        foreach (y; 0 .. h)
        {
            float zRe = (y - centerY) / (scaleCorrect * scaleFactor * height);
            foreach (x; 0 .. w)
            {
                float zIm = 1.5 * (x - centerX) / (scaleCorrect * scaleFactor * width);
                changeImageColor(zRe, zIm, x, y);
            }
        }
    }

    override RGBA calcColor(float x, float y)
    {
        import api.dm.kit.graphics.colors.hsva : HSVA;

        ComplexF z = ComplexF(x, y);
        ComplexF zPrev = ComplexF(0, 0);

        size_t i;
        for (i = 0; i < iterations; i++)
        {
            ComplexF zNext = z * z + coeffC + coeffP * zPrev;

            zPrev = z;
            z = zNext;

            if (z.abs >= 4)
            {
                RGBA color = HSVA((i * 2) % HSVA.maxHue, HSVA.maxSaturation, HSVA.maxValue * ((i < iterations) ? 1
                        : 0)).toRGBA;
                return color;
            }
        }

        return RGBA.black;
    }
}
