module api.dm.addon.procedural.noises.textures.noise;

import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.colors.hsva: HSVA;

/**
 * Authors: initkfs
 */
abstract class Noise : Texture2d
{
    HSVA noiseColor;

    this(float width = 100, float height = 100)
    {
        super(width, height);
    }

    override void create()
    {
        super.create;

        createMutRGBA32;
        assert(texture);

        drawOnTexture;
    }

    override bool recreate()
    {
        drawOnTexture;
        return true;
    }

    void drawOnTexture()
    {
        assert(texture);

        if (const err = texture.lock)
        {
            throw new Exception(err.toString);
        }

        scope (exit)
        {
            if (const err = texture.unlock)
            {
                throw new Exception(err.toString);
            }
        }

        auto w = cast(int) width;
        auto h = cast(int) height;
        foreach (int y; 0 .. h)
        {
            foreach (int x; 0 .. w)
            {
                RGBA color = drawNoise(x, y);
                if (const err = texture.setPixelColor(x, y, color.r, color.g, color.b, color.aByte))
                {
                    throw new Exception(err.toString);
                }
            }
        }
    }

    abstract RGBA drawNoise(int x, int y);
}
