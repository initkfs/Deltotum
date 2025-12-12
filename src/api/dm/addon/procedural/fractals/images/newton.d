module api.dm.addon.procedural.fractals.images.newton;

import api.dm.addon.procedural.fractals.images.complex_fractal_image : ComplexFractalImage;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.colors.hsva : HSVA;

import Math = api.dm.math;

import std.complex;

/**
 * Authors: initkfs
 */
class Newton : ComplexFractalImage
{
    protected
    {
        Complex!float[] roots;
        Complex!float c1 = Complex!float(1.0, 0);
        Complex!float c3 = Complex!float(3.0, 0);
    }

    this(float width = 100, float height = 100)
    {
        super(width, height);
    }

    override void initialize()
    {
        super.initialize;

        roots = [
            c1,
            Complex!float(-0.5, Math.sqrt(3.0) / 2.0),
            Complex!float(-0.5, -Math.sqrt(3.0) / 2.0)
        ];
    }

    override RGBA calcColor(float x, float y)
    {
        Complex!float z = Complex!float(x, y);

        size_t i;
        for (i = 0; i <= iterations; i++)
        {
            z = z - (((z ^^ 3) - c1) / (c3 * (z ^^ 2)));

            foreach (root; roots)
            {
                if (abs(z - root) <= 0.001)
                {
                    RGBA color = HSVA(i * 15 % HSVA.maxHue, HSVA.maxSaturation, HSVA.maxValue * (
                            (i < iterations) ? 1 : 0)).toRGBA;
                    return color;
                }
            }
        }

        return RGBA.black;
    }

}
