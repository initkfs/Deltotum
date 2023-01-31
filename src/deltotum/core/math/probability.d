module deltotum.core.math.probability;

/**
 * Authors: initkfs
 */
class Probability
{
    double probability(double countSuccessfulEvents, double allEvents) const pure nothrow @nogc @safe
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

    double probabilityInv(double countSuccessfulEvents, double allEvents) const pure nothrow @nogc @safe
    {
        return 1 - probability(countSuccessfulEvents, allEvents);
    }

    double probabilityFromAll(double nElements, double allElements){
        import deltotum.core.math.combinatorics: Combinatorics;

        if(nElements >= allElements){
            return 0;
        }
        auto comb = new Combinatorics;
        return comb.combinationsMfromN(nElements, allElements);
    }
}

unittest
{
    auto prob = new Probability;

    import std.math.operations : isClose;

    assert(isClose(prob.probability(1, 10), 0.1));
    assert(isClose(prob.probabilityInv(1, 10), 0.9));

    assert(prob.probabilityFromAll(2, 10) == 45);
}
