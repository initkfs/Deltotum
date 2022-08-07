module deltotum.math.random;

import std.random : uniform, StdRandom = Random;
import std.traits;

/**
 * Authors: initkfs
 */
struct Random
{

    private
    {
        StdRandom rnd;
    }

    this(int seed)
    {
        rnd = StdRandom(seed);
    }

    T randomBetween(T)(T minValue, T maxValue) if (isNumeric!T)
    {
        if (minValue == maxValue || minValue > maxValue)
        {
            return 0;
        }
        auto value = uniform(minValue, maxValue, rnd);
        return value;
    }
}
