module deltotum.core.maths.combinatorics;

/**
 * Authors: initkfs
 */

double combinationsMfromN(double m, double n) pure @nogc nothrow
{
    if (m >= n)
    {
        return 0;
    }
    import math = deltotum.core.maths.math;

    return math.factorial(n) / (math.factorial(m) * math.factorial(n - m));
}

double permutations(double n) pure @nogc nothrow
{
    import math = deltotum.core.maths.math;

    return math.factorial(n);
}

double permutationsMofN(double m, double n) pure @nogc nothrow
{
    if (m >= n)
    {
        return 0;
    }
    import math = deltotum.core.maths.math;

    return math.factorial(n) / math.factorial(n - m);
}

unittest
{
    import std.math.operations : isClose;

    assert(combinationsMfromN(3, 9) == 84);
    assert(isClose(permutations(9), 362_880));
    assert(isClose(permutationsMofN(3, 9), 504));
}
