module deltotum.core.math.probability;

/**
 * Authors: initkfs
 */
double probability(double countSuccessfulEvents, double allEvents) pure nothrow @nogc @safe
{
    import std.math.operations : isClose;

    if (isClose(countSuccessfulEvents, 0))
    {
        return 0;
    }

    if (isClose(countSuccessfulEvents, allEvents))
    {
        return 1;
    }

    return countSuccessfulEvents / allEvents;
}

double probabilityInv(double countSuccessfulEvents, double allEvents) pure nothrow @nogc @safe
{
    return 1 - probability(countSuccessfulEvents, allEvents);
}

double probabilityFromAll(double nElements, double allElements)
{
    import deltotum.core.math.combinatorics;

    if (nElements >= allElements)
    {
        return 0;
    }
    return combinationsMfromN(nElements, allElements);
}

unittest
{
    import std.math.operations : isClose;

    assert(isClose(probability(1, 10), 0.1));
    assert(isClose(probabilityInv(1, 10), 0.9));

    assert(probabilityFromAll(2, 10) == 45);
}
