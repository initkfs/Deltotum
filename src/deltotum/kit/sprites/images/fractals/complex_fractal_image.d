module deltotum.kit.sprites.images.fractals.complex_fractal_image;

import deltotum.kit.sprites.images.image : Image;
import deltotum.kit.graphics.colors.rgba : RGBA;
import Math = deltotum.math;

import std.complex;

/**
 * Authors: initkfs
 */
abstract class ComplexFractalImage : Image
{
    size_t iterations = 500;
    double scaleFactor = 1.0;

    this(double width = 100, double height = 100)
    {
        this.width = width;
        this.height = height;
    }

    RGBA calcColor(double x, double y)
    {
        return RGBA.white;
    }

    void createTextureContent(uint* pixels, int pitch)
    {
        const centerX = width / 2;
        const centerY = height / 2;

        foreach (yi; 0 .. cast(int) height)
        {
            double y = (centerY - yi) * scaleFactor;
            foreach (xi; 0 .. cast(int) width)
            {
                double x = (xi - centerX) * scaleFactor;
                
                RGBA color = calcColor(x, y);

                if (const err = texture.changeColor(xi, yi, pixels, pitch, color.r, color.g, color.b, color
                        .aNorm))
                {
                    throw new Exception(err.toString);
                }
            }
        }
    }

    override void create()
    {
        assert(width > 0);
        assert(height > 0);

        super.create;

        createMutableRGBA32;

        uint* pixels;
        int pitch;

        lock(pixels, pitch);
        scope (exit)
        {
            unlock;
        }

        createTextureContent(pixels, pitch);
    }

}
