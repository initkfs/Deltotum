module api.dm.kit.sprites3d.textures.noise_texture;

import api.dm.kit.sprites3d.textures.texture_gpu : TextureGPU;
import api.dm.kit.graphics.colors.hsva : HSVA;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.sims.procedural.noises.sample_noise : SampleNoise;

import Math = api.math;

/**
 * Authors: initkfs
 */

class NoiseTexture : TextureGPU
{
    float scale = 100;

    SampleNoise noise;

    this(SampleNoise noise = null)
    {
        this.noise = noise;

        if (!this.noise)
        {
            import api.dm.sims.procedural.noises.perlin : Perlin;

            this.noise = new Perlin;
        }

        isMipMaps = true;
    }

    override void create(int width, int height, RGBA color = RGBA.white)
    {
        auto image = graphic.comSurfaceProvider.getNew();
        scope (exit)
        {
            image.dispose;
        }

        auto textureFormat = gpu.dev.textureFormat;

        if (const err = image.createRGBA32(width, height))
        {
            throw new Exception(err.toString);
        }

        HSVA noiseColor = color.toHSVA;

        image.setPixelsRGBA((size_t x, size_t y, ref ubyte r, ref ubyte g, ref ubyte b, ref ubyte a) {
            float nx = (cast(float) x) / image.getWidth * scale;
            float ny = (cast(float) y) / image.getHeight * scale;
            float noiseValue = noise.sample2D(nx, ny);
            //float t = noiseValue * 0.5f + 0.5f;
            //t = Math.clamp(t, 0.0f, 1.0f);
            auto vColor = noiseColor;
            vColor.v = Math.clamp(noiseValue, HSVA.minValue, HSVA.maxValue);
            RGBA result = vColor.toRGBA;
            r = result.r;
            g = result.g;
            b = result.b;
            a = result.aByte;

            return true;
        });

        if (const err = image.convert(textureFormat))
        {
            throw new Exception(err.toString);
        }

        super.create(image);
    }
}
