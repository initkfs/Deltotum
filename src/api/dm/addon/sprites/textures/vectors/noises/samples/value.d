module api.dm.addon.sprites.textures.vectors.noises.samples.value;

import api.dm.addon.sprites.textures.vectors.noises.samples.sample_noise : SampleNoise;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.graphics.contexts.graphics_context : GraphicsContext;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.colors.hsv : HSV;
import api.dm.kit.graphics.contexts.graphics_context : GraphicsContext;
import api.dm.addon.sprites.textures.vectors.noises.samples.permutation_table : PermutationTable;

import Math = api.dm.math;

import std.random : unpredictableSeed;

/**
 * Authors: initkfs
 *
 * Ported from https://github.com/Scrawk/Procedural-Noise
 * Copyright (c) 2017 Justin Hawkins, under MIT license https://github.com/Scrawk/Procedural-Noise/blob/master/LICENSE
 */
class Value : SampleNoise
{
    this(uint seed = unpredictableSeed)
    {
        super(seed);
    }

    override float sample1D(float x)
    {
        x = (x + offsetX) * frequency;

        int ix0 = 0;
        float fx0 = 0;
        float s = 0, n0 = 0, n1 = 0;

        ix0 = cast(int) Math.floor(x); // Integer part of x
        fx0 = x - ix0; // Fractional part of x

        s = fade(fx0);

        n0 = perm[ix0];
        n1 = perm[ix0 + 1];

        // rescale from 0 to 255 to -1 to 1.
        float n = lerp(s, n0, n1) * perm.inverse;
        n = n * 2.0f - 1.0f;

        return n * amplitude;
    }

    override float sample2D(float x, float y)
    {
        x = (x + offsetX) * frequency;
        y = (y + offsetY) * frequency;

        int ix0, iy0;
        float fx0 = 0, fy0 = 0, s = 0, t = 0, nx0 = 0, nx1 = 0, n0 = 0, n1 = 0;

        ix0 = cast(int) Math.floor(x); // Integer part of x
        iy0 = cast(int) Math.floor(y); // Integer part of y

        fx0 = x - ix0; // Fractional part of x
        fy0 = y - iy0; // Fractional part of y

        t = fade(fy0);
        s = fade(fx0);

        nx0 = perm[ix0, iy0];
        nx1 = perm[ix0, iy0 + 1];

        n0 = lerp(t, nx0, nx1);

        nx0 = perm[ix0 + 1, iy0];
        nx1 = perm[ix0 + 1, iy0 + 1];

        n1 = lerp(t, nx0, nx1);

        // rescale from 0 to 255 to -1 to 1.
        float n = lerp(s, n0, n1) * perm.inverse;
        n = n * 2.0f - 1.0f;

        return n * amplitude;
    }

    override float sample3D(float x, float y, float z)
    {
        x = (x + offsetX) * frequency;
        y = (y + offsetY) * frequency;
        z = (z + offsetZ) * frequency;

        int ix0, iy0, iz0;
        float fx0 = 0, fy0 = 0, fz0 = 0;
        float s = 0, t = 0, r = 0;
        float nxy0 = 0, nxy1 = 0, nx0 = 0, nx1 = 0, n0 = 0, n1 = 0;

        ix0 = cast(int) Math.floor(x); // Integer part of x
        iy0 = cast(int) Math.floor(y); // Integer part of y
        iz0 = cast(int) Math.floor(z); // Integer part of z
        fx0 = x - ix0; // Fractional part of x
        fy0 = y - iy0; // Fractional part of y
        fz0 = z - iz0; // Fractional part of z

        r = fade(fz0);
        t = fade(fy0);
        s = fade(fx0);

        nxy0 = perm[ix0, iy0, iz0];
        nxy1 = perm[ix0, iy0, iz0 + 1];
        nx0 = lerp(r, nxy0, nxy1);

        nxy0 = perm[ix0, iy0 + 1, iz0];
        nxy1 = perm[ix0, iy0 + 1, iz0 + 1];
        nx1 = lerp(r, nxy0, nxy1);

        n0 = lerp(t, nx0, nx1);

        nxy0 = perm[ix0 + 1, iy0, iz0];
        nxy1 = perm[ix0 + 1, iy0, iz0 + 1];
        nx0 = lerp(r, nxy0, nxy1);

        nxy0 = perm[ix0 + 1, iy0 + 1, iz0];
        nxy1 = perm[ix0 + 1, iy0 + 1, iz0 + 1];
        nx1 = lerp(r, nxy0, nxy1);

        n1 = lerp(t, nx0, nx1);

        // rescale from 0 to 255 to -1 to 1.
        float n = lerp(s, n0, n1) * perm.inverse;
        n = n * 2.0f - 1.0f;

        return n * amplitude;
    }

    private float fade(float t)
    {
        return t * t * t * (t * (t * 6.0f - 15.0f) + 10.0f);
    }

    private float lerp(float t, float a, float b)
    {
        return a + t * (b - a);
    }
}
