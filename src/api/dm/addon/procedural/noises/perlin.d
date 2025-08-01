module api.dm.addon.procedural.noises.perlin;

import api.dm.addon.procedural.noises.sample_noise : SampleNoise;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.graphics.canvases.graphic_canvas : GraphicCanvas;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.colors.hsva : HSVA;
import api.dm.kit.graphics.canvases.graphic_canvas : GraphicCanvas;
import api.dm.addon.procedural.noises.permutation_table : PermutationTable;

import Math = api.dm.math;

import std.random : unpredictableSeed;

/**
 * Authors: initkfs
 *
 * Ported from https://github.com/Scrawk/Procedural-Noise
 * Copyright (c) 2017 Justin Hawkins, under MIT license https://github.com/Scrawk/Procedural-Noise/blob/master/LICENSE
 */
class Perlin : SampleNoise
{
    this(uint seed = unpredictableSeed)
    {
        super(seed);
    }

    override float sample1D(float x)
    {
        x = (x + offsetX) * frequency;

        int ix0;
        float fx0 = 0, fx1 = 0;
        float s = 0, n0 = 0, n1 = 0;

        ix0 = cast(int) Math.floor(x); // Integer part of x
        fx0 = x - ix0; // Fractional part of x
        fx1 = fx0 - 1.0f;

        s = fade(fx0);

        n0 = grad(perm[ix0], fx0);
        n1 = grad(perm[ix0 + 1], fx1);

        return 0.25f * lerp(s, n0, n1) * amplitude;
    }

    override float sample2D(float x, float y)
    {
        x = (x + offsetX) * frequency;
        y = (y + offsetY) * frequency;

        int ix0, iy0;
        float fx0 = 0, fy0 = 0, fx1 = 0, fy1 = 0, s = 0, t = 0, nx0 = 0, nx1 = 0, n0 = 0, n1 = 0;

        ix0 = cast(int) Math.floor(x); // Integer part of x
        iy0 = cast(int) Math.floor(y); // Integer part of y

        fx0 = x - ix0; // Fractional part of x
        fy0 = y - iy0; // Fractional part of y
        fx1 = fx0 - 1.0f;
        fy1 = fy0 - 1.0f;

        t = fade(fy0);
        s = fade(fx0);

        nx0 = grad(perm[ix0, iy0], fx0, fy0);
        nx1 = grad(perm[ix0, iy0 + 1], fx0, fy1);

        n0 = lerp(t, nx0, nx1);

        nx0 = grad(perm[ix0 + 1, iy0], fx1, fy0);
        nx1 = grad(perm[ix0 + 1, iy0 + 1], fx1, fy1);

        n1 = lerp(t, nx0, nx1);

        return 0.66666f * lerp(s, n0, n1) * amplitude;
    }

    public override float sample3D(float x, float y, float z)
    {
        x = (x + offsetX) * frequency;
        y = (y + offsetY) * frequency;
        z = (z + offsetZ) * frequency;

        int ix0, iy0, iz0;
        float fx0 = 0, fy0 = 0, fz0 = 0, fx1 = 0, fy1 = 0, fz1 = 0;
        float s = 0, t = 0, r = 0;
        float nxy0 = 0, nxy1 = 0, nx0 = 0, nx1 = 0, n0 = 0, n1 = 0;

        ix0 = cast(int) Math.floor(x); // Integer part of x
        iy0 = cast(int) Math.floor(y); // Integer part of y
        iz0 = cast(int) Math.floor(z); // Integer part of z
        fx0 = x - ix0; // Fractional part of x
        fy0 = y - iy0; // Fractional part of y
        fz0 = z - iz0; // Fractional part of z
        fx1 = fx0 - 1.0f;
        fy1 = fy0 - 1.0f;
        fz1 = fz0 - 1.0f;

        r = fade(fz0);
        t = fade(fy0);
        s = fade(fx0);

        nxy0 = grad(perm[ix0, iy0, iz0], fx0, fy0, fz0);
        nxy1 = grad(perm[ix0, iy0, iz0 + 1], fx0, fy0, fz1);
        nx0 = lerp(r, nxy0, nxy1);

        nxy0 = grad(perm[ix0, iy0 + 1, iz0], fx0, fy1, fz0);
        nxy1 = grad(perm[ix0, iy0 + 1, iz0 + 1], fx0, fy1, fz1);
        nx1 = lerp(r, nxy0, nxy1);

        n0 = lerp(t, nx0, nx1);

        nxy0 = grad(perm[ix0 + 1, iy0, iz0], fx1, fy0, fz0);
        nxy1 = grad(perm[ix0 + 1, iy0, iz0 + 1], fx1, fy0, fz1);
        nx0 = lerp(r, nxy0, nxy1);

        nxy0 = grad(perm[ix0 + 1, iy0 + 1, iz0], fx1, fy1, fz0);
        nxy1 = grad(perm[ix0 + 1, iy0 + 1, iz0 + 1], fx1, fy1, fz1);
        nx1 = lerp(r, nxy0, nxy1);

        n1 = lerp(t, nx0, nx1);

        return 1.1111f * lerp(s, n0, n1) * amplitude;
    }

    private float fade(float t)
    {
        return t * t * t * (t * (t * 6.0f - 15.0f) + 10.0f);
    }

    private float lerp(float t, float a, float b)
    {
        return a + t * (b - a);
    }

    private float grad(int hash, float x)
    {
        int h = hash & 15;
        float grad = 1.0f + (h & 7); // Gradient value 1.0, 2.0, ..., 8.0
        if ((h & 8) != 0)
            grad = -grad; // Set a random sign for the gradient
        return (grad * x); // Multiply the gradient with the distance
    }

    private float grad(int hash, float x, float y)
    {
        int h = hash & 7; // Convert low 3 bits of hash code
        float u = h < 4 ? x : y; // into 8 simple gradient directions,
        float v = h < 4 ? y : x; // and compute the dot product with (x,y).
        return ((h & 1) != 0 ? -u : u) + ((h & 2) != 0 ? -2.0f * v : 2.0f * v);
    }

    private float grad(int hash, float x, float y, float z)
    {
        int h = hash & 15; // Convert low 4 bits of hash code into 12 simple
        float u = h < 8 ? x : y; // gradient directions, and compute dot product.
        float v = h < 4 ? y : h == 12 || h == 14 ? x : z; // Fix repeats at h = 12 to 15
        return ((h & 1) != 0 ? -u : u) + ((h & 2) != 0 ? -v : v);
    }

    private float grad(int hash, float x, float y, float z, float t)
    {
        int h = hash & 31; // Convert low 5 bits of hash code into 32 simple
        float u = h < 24 ? x : y; // gradient directions, and compute dot product.
        float v = h < 16 ? y : z;
        float w = h < 8 ? z : t;
        return ((h & 1) != 0 ? -u : u) + ((h & 2) != 0 ? -v : v) + ((h & 4) != 0 ? -w : w);
    }

}
