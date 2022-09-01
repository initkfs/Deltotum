module deltotum.math.random;

import std.random : uniform, unpredictableSeed, StdRandom = Random;
import std.range.primitives;
import std.traits;

/**
 * Authors: initkfs
 */
class Random
{

    private
    {
        StdRandom rnd;
    }

    this(uint seed = unpredictableSeed)
    {
        rnd = StdRandom(seed);
    }

    T randomBetween(T)(T minValueInclusive, T maxValueInclusive) if (isNumeric!T)
    {
        if (minValueInclusive == maxValueInclusive)
        {
            return minValueInclusive;
        }

        if (minValueInclusive > maxValueInclusive)
        {
            //TODO or error\exception?
            return 0;
        }

        T value = uniform!"[]"(minValueInclusive, maxValueInclusive, rnd);
        return value;
    }

    auto randomElement(T)(T container)
            if (
                __traits(compiles, assert(container[0])) &&
            __traits(compiles, 0 == container.length))
    {
        immutable containerLength = container.length;
        if (containerLength == 0)
        {
            throw new Exception("Container must not be empty");
        }

        if (containerLength == 1)
        {
            return container[0];
        }

        immutable size_t index = randomBetween!size_t(0, containerLength - 1);
        return container[index];
    }

    R shuffle(R)(R range) if (isRandomAccessRange!R)
    {
        import std.random : randomShuffle;

        return randomShuffle(range, rnd);
    }
}
