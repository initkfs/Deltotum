module deltotum.kit.addons.sprites.images.fractals.newton;

import deltotum.kit.addons.sprites.images.fractals.complex_fractal_image : ComplexFractalImage;
import deltotum.kit.graphics.colors.rgba : RGBA;
import deltotum.kit.graphics.colors.hsv : HSV;

import Math = deltotum.math;

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

                    RGBA color = HSV(i * 15 % HSV.maxHue, HSV.maxSaturation, HSV.maxValue * (
                            (i < iterations) ? 1 : 0)).toRGBA;
                    return color;
                }
            }
        }

        return RGBA.black;
    }

}
