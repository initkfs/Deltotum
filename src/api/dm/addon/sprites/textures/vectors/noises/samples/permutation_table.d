module api.dm.addon.sprites.textures.vectors.noises.samples.permutation_table;

import Math = api.dm.math;
import api.math.random : Random;
import std.random : unpredictableSeed;
import std.conv : to;

/**
 * Authors: initkfs
 *
 * Ported from https://github.com/Scrawk/Procedural-Noise
 * Copyright (c) 2017 Justin Hawkins, under MIT license https://github.com/Scrawk/Procedural-Noise/blob/master/LICENSE
 */
class PermutationTable(size_t Size) if (Size > 1)
{
    private
    {
        Random rnd;
        int[Size] table;
        int wrap;
        uint _seed;
    }

    int max;
    float inverse = 0;

    this(int max, uint seed = unpredictableSeed)
    {
        this.wrap = Size - 1;
        this.max = Math.max(1, max);
        this.inverse = 1.0 / max;
        this._seed = seed;

        this.rnd = new Random(seed);

        foreach (i; 0 .. Size)
        {
            table[i] = rnd.between!int(0, int.max);
        }
    }

    void seed(uint newSeed)
    {
        _seed = newSeed;
        rnd.seed = newSeed;
    }

    uint seed()
    {
        return _seed;
    }

    int opIndex(int i)
    {
        return table[i & wrap] & max;
    }

    int opIndex(int i, int j)
    {
        return table[(j + table[i & wrap]) & wrap] & max;
    }

    int opIndex(int i, int j, int k)
    {
        return table[(k + table[(j + table[i & wrap]) & wrap]) & wrap] & max;
    }

}
