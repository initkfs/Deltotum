module api.dm.addon.sprites.textures.vectors.noises.samples.fractal_noise;

import api.dm.kit.sprites.sprites2d.textures.texture2d : Texture2d;
import api.dm.addon.sprites.textures.vectors.noises.noise : Noise;
import api.dm.addon.sprites.textures.vectors.noises.samples.sample_noise : SampleNoise;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.colors.hsv : HSV;

import Math = api.dm.math;

/**
 * Authors: initkfs
 *
 * Ported from https://github.com/Scrawk/Procedural-Noise
 * Copyright (c) 2017 Justin Hawkins, under MIT license https://github.com/Scrawk/Procedural-Noise/blob/master/LICENSE
 */
class FractalNoise : Texture2d
{
    int octaves;
    float frequency = 0;
    float amplitude = 0;
    float offsetX = 0;
    float offsetY = 0;
    float offsetZ = 0;

    HSV noiseColor = HSV(0, 0.3, 1);
    float valueScale = 1;

    //The rate at which the amplitude changes.
    float lacunarity = 0;
    /// The rate at which the frequency changes.
    float gain = 0;
    /// The noises to sample from to generate the fractal.
    SampleNoise[] noises;
    /// The amplitudes for each octave.
    float[] amplitudes;
    /// The frequencies for each octave.
    float[] frequencies;

    this(double width = 100, double height = 100, int octaves = 4, float frequency = 1.0, float amplitude = 1.0f)
    {
        super(width, height);
        this.octaves = octaves;
        this.frequency = frequency;
        this.amplitude = amplitude;
        this.lacunarity = 2.0f;
        this.gain = 0.5f;
    }

    this(SampleNoise noise, double width = 100, double height = 100, int octaves = 4, float frequency = 1.0, float amplitude = 1.0f)
    {
        this(width, height, octaves, frequency, amplitude);
        updateTable([noise]);
    }

    this(SampleNoise[] noises, double width = 100, double height = 100, int octaves = 4, float frequency = 1.0, float amplitude = 1.0f)
    {
        this(width, height, octaves, frequency, amplitude);
        updateTable(noises);
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

        //TODO huge allocation
        float[][] noiseValues = new float[][](h, w);
        foreach (y; 0 .. h)
        {
            foreach (x; 0 .. w)
            {
                float fx = x / (width - 1.0f);
                float fy = y / (height - 1.0f);

                noiseValues[y][x] = sample2D(fx, fy);
            }
        }

        normalizeArray(noiseValues, w, h);

        auto newColor = noiseColor;

        foreach (y; 0 .. h)
        {
            foreach (x; 0 .. w)
            {
                float n = noiseValues[y][x];
                //ubyte b = cast(ubyte)(n * ubyte.max);
                newColor.value = Math.clamp(n * valueScale, HSV.minValue, HSV.maxValue);
                color = newColor.toRGBA;
                if (const err = texture.setPixelColor(x, y, color.r, color.g, color.b, color.aByte))
                {
                    throw new Exception(err.toString);
                }
            }
        }

    }

    protected void updateTable(SampleNoise[] newNoises)
    {
        assert(octaves > 0);
        assert(newNoises.length > 0);

        amplitudes = new float[](octaves);
        frequencies = new float[](octaves);
        noises = new SampleNoise[](octaves);

        int numNoises = cast(int) newNoises.length;

        float amp = 0.5f;
        float frq = frequency;
        foreach (i; 0 .. octaves)
        {
            noises[i] = newNoises[Math.min(i, numNoises - 1)];
            frequencies[i] = frq;
            amplitudes[i] = amp;
            amp *= gain;
            frq *= lacunarity;
        }
    }

    float octave1D(int i, float x)
    {
        assert(i >= 0);
        assert(i < noises.length);
        assert(i < amplitudes.length);
        assert(i < frequencies.length);

        if (i >= octaves)
            return 0.0f;
        if (!noises[i])
            return 0.0f;

        x = x + offsetX;

        float frq = frequencies[i];
        return noises[i].sample1D(x * frq) * amplitudes[i] * amplitude;
    }

    float octave2D(int i, float x, float y)
    {
        assert(i >= 0);
        assert(i < noises.length);
        assert(i < amplitudes.length);
        assert(i < frequencies.length);

        if (i >= octaves)
            return 0.0f;
        if (!noises[i])
            return 0.0f;

        x = x + offsetX;
        y = y + offsetY;

        float frq = frequencies[i];
        return noises[i].sample2D(x * frq, y * frq) * amplitudes[i] * amplitude;
    }

    public float octave3D(int i, float x, float y, float z)
    {
        assert(i >= 0);
        assert(i < noises.length);
        assert(i < amplitudes.length);
        assert(i < frequencies.length);

        if (i >= octaves)
            return 0.0f;
        if (!noises[i])
            return 0.0f;

        x = x + offsetX;
        y = y + offsetY;
        z = z + offsetZ;

        float frq = frequencies[i];
        return noises[i].sample3D(x * frq, y * frq, z * frq) * amplitudes[i] * amplitude;
    }

    float sample1D(float x)
    {
        x = x + offsetX;

        float sum = 0, frq = 0;
        foreach (i; 0 .. octaves)
        {
            frq = frequencies[i];

            if (noises[i])
                sum += noises[i].sample1D(x * frq) * amplitudes[i];
        }
        return sum * amplitude;
    }

    public float sample2D(float x, float y)
    {
        x = x + offsetX;
        y = y + offsetY;

        float sum = 0, frq = 0;
        foreach (i; 0 .. octaves)
        {
            frq = frequencies[i];

            if (noises[i])
                sum += noises[i].sample2D(x * frq, y * frq) * amplitudes[i];
        }
        return sum * amplitude;
    }

    public float sample3D(float x, float y, float z)
    {
        x = x + offsetX;
        y = y + offsetY;
        z = z + offsetZ;

        float sum = 0, frq = 0;
        foreach (i; 0 .. octaves)
        {
            frq = frequencies[i];

            if (noises[i])
                sum += noises[i].sample3D(x * frq, y * frq, z * frq) * amplitudes[i];
        }
        return sum * amplitude;
    }

    private void normalizeArray(float[][] arr, int w, int h)
    {
        //TODO check bounds
        float min = float.infinity;
        float max = -float.infinity;

        foreach (y; 0 .. h)
        {
            foreach (x; 0 .. w)
            {
                float v = arr[y][x];
                if (v < min)
                    min = v;
                if (v > max)
                    max = v;
            }
        }

        foreach (y; 0..h)
        {
            foreach (x; 0..w)
            {
                float v = arr[y][x];
                arr[y][x] = (v - min) / (max - min);
            }
        }
    }
}
