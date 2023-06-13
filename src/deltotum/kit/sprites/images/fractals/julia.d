module deltotum.kit.sprites.images.fractals.julia;

import deltotum.kit.sprites.images.fractals.complex_fractal_image : ComplexFractalImage;
import deltotum.kit.graphics.colors.rgba : RGBA;

import Math = deltotum.math;

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
    override void createTextureContent(uint* pixels, int pitch)
    {
        const centerY = height / 2;
        const centerX = width / 2;
        enum scaleCorrect = 0.5;

        foreach (y; 0 .. cast(int) height)
        {
            double zRe = (y - centerY) / (scaleCorrect * scaleFactor * height);
            foreach (x; 0 .. cast(int) width)
            {
                double zIm = 1.5 * (x - centerX) / (scaleCorrect * scaleFactor * width);
                
                RGBA color = calcColor(zRe, zIm);

                if (const err = texture.changeColor(x, y, pixels, pitch, color.r, color.g, color.b, color
                        .aNorm))
                {
                    throw new Exception(err.toString);
                }
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

        import deltotum.kit.graphics.colors.hsv : HSV;

        //or iter step? iter/max
        RGBA color = HSV((i * 2) % HSV.HSVData.maxHue, HSV.HSVData.maxSaturation, HSV.HSVData.maxValue * ((i < iterations) ? 1 : 0)).toRGBA;
        return color;
    }
}
