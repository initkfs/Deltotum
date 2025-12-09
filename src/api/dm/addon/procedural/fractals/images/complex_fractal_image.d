module api.dm.addon.procedural.fractals.images.complex_fractal_image;

import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import Math = api.dm.math;

import std.complex;

/**
 * Authors: initkfs
 */
abstract class ComplexFractalImage : Texture2d
{
    size_t iterations = 500;
    float scaleFactor = 1.0;

    this(float width = 100, float height = 100)
    {
        this.width = width;
        this.height = height;
    }

    RGBA calcColor(float x, float y)
    {
        return RGBA.white;
    }

    void createTextureContent()
    {
        lock;
        scope (exit)
        {
            unlock;
        }

        const centerX = width / 2;
        const centerY = height / 2;

        const size_t w = cast(size_t) width;
        const size_t h = cast(size_t) height;

        foreach (yi; 0 .. h)
        {
            float y = (centerY - yi) * scaleFactor;
            foreach (xi; 0 .. w)
            {
                float x = (xi - centerX) * scaleFactor;

                RGBA color = calcColor(x, y);

                changeColor(cast(uint) xi, cast(uint) yi, color);
            }
        }
    }

    override void create()
    {
        assert(width > 0);
        assert(height > 0);

        super.create;

        createMutRGBA32;
        createTextureContent;
    }

}
