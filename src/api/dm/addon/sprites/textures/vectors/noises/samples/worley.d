module api.dm.addon.sprites.textures.vectors.noises.samples.worley;

import api.dm.addon.sprites.textures.vectors.noises.samples.sample_noise : SampleNoise;
import api.dm.addon.sprites.textures.vectors.noises.samples.voronoi: VoronoiDistance, VoronoiCombination;
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
class Worley : SampleNoise
{
    static float[3] offsetF = [-0.5f, 0.5f, 1.5f];

    enum float K = 1.0f / 7.0f;
    enum float Ko = 3.0f / 7.0f;

    float jitter = 1.0;

    public VoronoiDistance distance = VoronoiDistance.EUCLIDIAN;
    public VoronoiCombination combination = VoronoiCombination.D1_D0;

    this(uint seed = unpredictableSeed)
    {
        super(seed);
    }

    override float sample1D(float x)
    {
        x = (x + offsetX) * frequency;

        int Pi0 = cast(int) Math.floor(x);
        float Pf0 = frac(x);

        float[3] pX = 0;
        pX[0] = perm[Pi0 - 1];
        pX[1] = perm[Pi0];
        pX[2] = perm[Pi0 + 1];

        float d0 = 0, d1 = 0, d2 = 0;
        float F0 = float.infinity;
        float F1 = float.infinity;
        float F2 = float.infinity;

        int px, py, pz;
        float oxx = 0, oxy = 0, oxz = 0;

        px = perm[cast(int) pX[0]];
        py = perm[cast(int) pX[1]];
        pz = perm[cast(int) pX[2]];

        oxx = frac(px * K) - Ko;
        oxy = frac(py * K) - Ko;
        oxz = frac(pz * K) - Ko;

        d0 = distance1(Pf0, offsetF[0] + jitter * oxx);
        d1 = distance1(Pf0, offsetF[1] + jitter * oxy);
        d2 = distance1(Pf0, offsetF[2] + jitter * oxz);

        if (d0 < F0)
        {
            F2 = F1;
            F1 = F0;
            F0 = d0;
        }
        else if (d0 < F1)
        {
            F2 = F1;
            F1 = d0;
        }
        else if (d0 < F2)
        {
            F2 = d0;
        }

        if (d1 < F0)
        {
            F2 = F1;
            F1 = F0;
            F0 = d1;
        }
        else if (d1 < F1)
        {
            F2 = F1;
            F1 = d1;
        }
        else if (d1 < F2)
        {
            F2 = d1;
        }

        if (d2 < F0)
        {
            F2 = F1;
            F1 = F0;
            F0 = d2;
        }
        else if (d2 < F1)
        {
            F2 = F1;
            F1 = d2;
        }
        else if (d2 < F2)
        {
            F2 = d2;
        }

        return combine(F0, F1, F2) * amplitude;
    }

    override float sample2D(float x, float y)
    {
        x = (x + offsetX) * frequency;
        y = (y + offsetY) * frequency;

        int Pi0 = cast(int) Math.floor(x);
        int Pi1 = cast(int) Math.floor(y);

        float Pf0 = frac(x);
        float Pf1 = frac(y);

        float[3] pX = 0;
        pX[0] = perm[Pi0 - 1];
        pX[1] = perm[Pi0];
        pX[2] = perm[Pi0 + 1];

        float d0, d1, d2;
        float F0 = float.infinity;
        float F1 = float.infinity;
        float F2 = float.infinity;

        int px, py, pz;
        float oxx, oxy, oxz;
        float oyx, oyy, oyz;

        for (int i = 0; i < 3; i++)
        {
            px = perm[cast(int) pX[i], Pi1 - 1];
            py = perm[cast(int) pX[i], Pi1];
            pz = perm[cast(int) pX[i], Pi1 + 1];

            oxx = frac(px * K) - Ko;
            oxy = frac(py * K) - Ko;
            oxz = frac(pz * K) - Ko;

            oyx = modN(Math.floor(px * K), 7.0f) * K - Ko;
            oyy = modN(Math.floor(py * K), 7.0f) * K - Ko;
            oyz = modN(Math.floor(pz * K), 7.0f) * K - Ko;

            d0 = distance2(Pf0, Pf1, offsetF[i] + jitter * oxx, -0.5f + jitter * oyx);
            d1 = distance2(Pf0, Pf1, offsetF[i] + jitter * oxy, 0.5f + jitter * oyy);
            d2 = distance2(Pf0, Pf1, offsetF[i] + jitter * oxz, 1.5f + jitter * oyz);

            if (d0 < F0)
            {
                F2 = F1;
                F1 = F0;
                F0 = d0;
            }
            else if (d0 < F1)
            {
                F2 = F1;
                F1 = d0;
            }
            else if (d0 < F2)
            {
                F2 = d0;
            }

            if (d1 < F0)
            {
                F2 = F1;
                F1 = F0;
                F0 = d1;
            }
            else if (d1 < F1)
            {
                F2 = F1;
                F1 = d1;
            }
            else if (d1 < F2)
            {
                F2 = d1;
            }

            if (d2 < F0)
            {
                F2 = F1;
                F1 = F0;
                F0 = d2;
            }
            else if (d2 < F1)
            {
                F2 = F1;
                F1 = d2;
            }
            else if (d2 < F2)
            {
                F2 = d2;
            }

        }

        return combine(F0, F1, F2) * amplitude;
    }

    override float sample3D(float x, float y, float z)
    {
        x = (x + offsetX) * frequency;
        y = (y + offsetY) * frequency;
        z = (z + offsetZ) * frequency;

        int Pi0 = cast(int) Math.floor(x);
        int Pi1 = cast(int) Math.floor(y);
        int Pi2 = cast(int) Math.floor(z);

        float Pf0 = frac(x);
        float Pf1 = frac(y);
        float Pf2 = frac(z);

        float[3] pX = 0;
        pX[0] = perm[Pi0 - 1];
        pX[1] = perm[Pi0];
        pX[2] = perm[Pi0 + 1];

        float[3] pY = 0;
        pY[0] = perm[Pi1 - 1];
        pY[1] = perm[Pi1];
        pY[2] = perm[Pi1 + 1];

        float d0 = 0, d1 = 0, d2 = 0;
        float F0 = 1e6f;
        float F1 = 1e6f;
        float F2 = 1e6f;

        int px, py, pz;
        float oxx = 0, oxy = 0, oxz = 0;
        float oyx = 0, oyy = 0, oyz = 0;
        float ozx = 0, ozy = 0, ozz = 0;

        for (int i = 0; i < 3; i++)
        {
            for (int j = 0; j < 3; j++)
            {

                px = perm[cast(int) pX[i], cast(int) pY[j], Pi2 - 1];
                py = perm[cast(int) pX[i], cast(int) pY[j], Pi2];
                pz = perm[cast(int) pX[i], cast(int) pY[j], Pi2 + 1];

                oxx = frac(px * K) - Ko;
                oxy = frac(py * K) - Ko;
                oxz = frac(pz * K) - Ko;

                oyx = modN(Math.floor(px * K), 7.0f) * K - Ko;
                oyy = modN(Math.floor(py * K), 7.0f) * K - Ko;
                oyz = modN(Math.floor(pz * K), 7.0f) * K - Ko;

                px = perm[px];
                py = perm[py];
                pz = perm[pz];

                ozx = frac(px * K) - Ko;
                ozy = frac(py * K) - Ko;
                ozz = frac(pz * K) - Ko;

                d0 = distance3(Pf0, Pf1, Pf2, offsetF[i] + jitter * oxx, offsetF[j] + jitter * oyx, -0.5f + jitter * ozx);
                d1 = distance3(Pf0, Pf1, Pf2, offsetF[i] + jitter * oxy, offsetF[j] + jitter * oyy, 0.5f + jitter * ozy);
                d2 = distance3(Pf0, Pf1, Pf2, offsetF[i] + jitter * oxz, offsetF[j] + jitter * oyz, 1.5f + jitter * ozz);

                if (d0 < F0)
                {
                    F2 = F1;
                    F1 = F0;
                    F0 = d0;
                }
                else if (d0 < F1)
                {
                    F2 = F1;
                    F1 = d0;
                }
                else if (d0 < F2)
                {
                    F2 = d0;
                }

                if (d1 < F0)
                {
                    F2 = F1;
                    F1 = F0;
                    F0 = d1;
                }
                else if (d1 < F1)
                {
                    F2 = F1;
                    F1 = d1;
                }
                else if (d1 < F2)
                {
                    F2 = d1;
                }

                if (d2 < F0)
                {
                    F2 = F1;
                    F1 = F0;
                    F0 = d2;
                }
                else if (d2 < F1)
                {
                    F2 = F1;
                    F1 = d2;
                }
                else if (d2 < F2)
                {
                    F2 = d2;
                }
            }
        }

        return combine(F0, F1, F2) * amplitude;
    }

    private float modN(float x, float y)
    {
        return x - y * Math.floor(x / y);
    }

    private float frac(float v)
    {
        return v - Math.floor(v);
    }

    private float distance1(float p1x, float p2x)
    {
        final switch (distance)
        {
            case VoronoiDistance.EUCLIDIAN:
                return (p1x - p2x) * (p1x - p2x);

            case VoronoiDistance.MANHATTAN:
                return Math.abs(p1x - p2x);

            case VoronoiDistance.CHEBYSHEV:
                return Math.abs(p1x - p2x);
        }

        return 0;
    }

    private float distance2(float p1x, float p1y, float p2x, float p2y)
    {
        final switch (distance)
        {
            case VoronoiDistance.EUCLIDIAN:
                return (p1x - p2x) * (p1x - p2x) + (p1y - p2y) * (p1y - p2y);
            case VoronoiDistance.MANHATTAN:
                return Math.abs(p1x - p2x) + Math.abs(p1y - p2y);
            case VoronoiDistance.CHEBYSHEV:
                return Math.max(Math.abs(p1x - p2x), Math.abs(p1y - p2y));
        }

        return 0;
    }

    private float distance3(float p1x, float p1y, float p1z, float p2x, float p2y, float p2z)
    {
        final switch (distance)
        {
            case VoronoiDistance.EUCLIDIAN:
                return (p1x - p2x) * (p1x - p2x) + (p1y - p2y) * (p1y - p2y) + (
                    p1z - p2z) * (p1z - p2z);

            case VoronoiDistance.MANHATTAN:
                return Math.abs(p1x - p2x) + Math.abs(p1y - p2y) + Math.abs(p1z - p2z);

            case VoronoiDistance.CHEBYSHEV:
                return Math.max(Math.max(Math.abs(p1x - p2x), Math.abs(p1y - p2y)), Math.abs(
                        p1z - p2z));
        }

        return 0;
    }

    private float combine(float f0, float f1, float f2)
    {
        final switch (combination)
        {
            case VoronoiCombination.D0:
                return f0;
            case VoronoiCombination.D1_D0:
                return f1 - f0;
            case VoronoiCombination.D2_D0:
                return f2 - f0;
        }

        return 0;
    }
}
