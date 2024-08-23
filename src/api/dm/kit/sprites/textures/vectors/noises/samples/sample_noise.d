module api.dm.kit.sprites.textures.vectors.noises.samples.sample_noise;
import api.dm.kit.sprites.textures.vectors.noises.samples.permutation_table : PermutationTable;

import std.random : unpredictableSeed;

/**
 * Authors: initkfs
 *
 * Ported from https://github.com/Scrawk/Procedural-Noise
 * Copyright (c) 2017 Justin Hawkins, under MIT license https://github.com/Scrawk/Procedural-Noise/blob/master/LICENSE
 */
abstract class SampleNoise
{
    float frequency = 1.0;
    float amplitude = 1.0;
    float offsetX = 0;
    float offsetY = 0;
    float offsetZ = 0;

    enum PermTableSize = 1024;

    protected {
        PermutationTable!PermTableSize perm;
    }

    private
    {
        uint _seed;
    }

    this(uint seed = unpredictableSeed)
    {
        this._seed = seed;
        perm = new PermutationTable!(PermTableSize)(255, seed);
    }

    uint seed()
    {
        return _seed;
    }

    void seed(uint newSeed)
    {
        assert(perm);
        _seed = newSeed;
        perm.seed = newSeed;
    }

    float sample1D(float x);
    float sample2D(float x, float y);
    float sample3D(float x, float y, float z);
}
