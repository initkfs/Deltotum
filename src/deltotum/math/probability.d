module deltotum.math.probability;

/**
 * Authors: initkfs
 */
double probability(size_t countSuccessfulEvents, size_t allEvents) pure nothrow @nogc @safe
{
    import std.math.operations : cmp;

    if (countSuccessfulEvents == 0 || allEvents == 0)
    {
        return 0;
    }

    if (countSuccessfulEvents == allEvents)
    {
        return 1;
    }

    return countSuccessfulEvents / cast(real) allEvents;
}

double probabilityInv(size_t countSuccessfulEvents, size_t allEvents) pure nothrow @nogc @safe
{
    return 1 - probability(countSuccessfulEvents, allEvents);
}

size_t probabilityFromAll(size_t nElements, size_t allElements)
{
    import deltotum.math.combinatorics;

    if (nElements == 0 || allElements == 0 || nElements >= allElements)
    {
        return 0;
    }
    return combinationCountMfromN(nElements, allElements);
}

unittest
{
    import std.math.operations : isClose;

    assert(isClose(probability(1, 10), 0.1));
    assert(isClose(probabilityInv(1, 10), 0.9));

    assert(probabilityFromAll(2, 10) == 45);
}
