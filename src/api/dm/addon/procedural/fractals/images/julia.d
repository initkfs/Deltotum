module api.dm.addon.procedural.fractals.images.julia;

import api.dm.addon.procedural.fractals.images.complex_fractal_image : ComplexFractalImage;
import api.dm.kit.graphics.colors.rgba : RGBA;

import Math = api.dm.math;

import std.complex;

/**
 * Authors: initkfs
 */
class Julia : ComplexFractalImage
{
    private {
        Complex!double coeffC = Complex!double(-0.7, 0.27015);
    }

    this(double width = 100, double height = 100, double scaleFactor = 2.0, size_t iterations = 200)
    {
        super(width, height);
        this.scaleFactor = scaleFactor;
        this.iterations = iterations;
    }

    //TODO remove duplication with parent class
    override void createTextureContent()
    {
        lock;
        scope(exit){
            unlock;

        }
        const centerY = height / 2;
        const centerX = width / 2;
        enum scaleCorrect = 0.5;

        const size_t w = cast(size_t) width;
        const size_t h = cast(size_t) height;

        foreach (y; 0 .. h)
        {
            double zRe = (y - centerY) / (scaleCorrect * scaleFactor * height);
            foreach (x; 0 .. w)
            {
                double zIm = 1.5 * (x - centerX) / (scaleCorrect * scaleFactor * width);
                
                RGBA color = calcColor(zRe, zIm);

                changeColor(cast(uint) x, cast(uint) y, color);
            }
        }
    }

    override RGBA calcColor(double x, double y)
    {
        Complex!double z = Complex!double(x, y);
        size_t i;
        for (i = 0; i < iterations; i++)
        {
            z = z * z + coeffC;
            if (z.abs >= 4)
            {
                break;
            }
        }

        import api.dm.kit.graphics.colors.hsva : HSVA;

        //or iter step? iter/max
        RGBA color = HSVA((i * 2) % HSVA.maxHue, HSVA.maxSaturation, HSVA.maxValue * ((i < iterations) ? 1 : 0)).toRGBA;
        return color;
    }
}
