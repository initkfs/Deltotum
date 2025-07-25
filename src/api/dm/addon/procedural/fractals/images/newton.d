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
        Complex!double[] roots;
        Complex!double c1 = Complex!double(1.0, 0);
        Complex!double c3 = Complex!double(3.0, 0);
    }

    this(double width = 100, double height = 100)
    {
        super(width, height);
    }

    override void initialize()
    {
        super.initialize;

        roots = [
            c1,
            Complex!double(-0.5, Math.sqrt(3.0) / 2.0),
            Complex!double(-0.5, -Math.sqrt(3.0) / 2.0)
        ];
    }

    override RGBA calcColor(double x, double y)
    {
        Complex!double z = Complex!double(x, y);

        size_t i;
        for (i = 0; i <= iterations; i++)
        {
            z = z - (((z ^^ 3) - c1) / (c3 * (z ^^ 2)));

            foreach (root; roots)
            {
                if (abs(z - root) <= 0.001)
                {
                    import std;

                    RGBA color = HSVA(i * 15 % HSVA.maxHue, HSVA.maxSaturation, HSVA.maxValue * (
                            (i < iterations) ? 1 : 0)).toRGBA;
                    return color;
                }
            }
        }

        return RGBA.black;
    }

}
