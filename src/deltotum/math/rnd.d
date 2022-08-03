module deltotum.math.rnd;

import std.random : uniform, Random;
import std.traits;

/**
 * Authors: initkfs
 */
struct Rnd
{

    private
    {
        Random rnd;
    }

    this(int seed)
    {
        rnd = Random(seed);
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
