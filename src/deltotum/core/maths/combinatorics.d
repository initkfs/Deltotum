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

/** 
 * https://www.quickperm.org
 */
import std.traits;

T[][] permutations(T)(in T[] container) pure nothrow @safe if (!is(T == void))
{
    T[][] result;
    immutable containerLength = container.length;
    if (containerLength == 0)
    {
        return result;
    }

    result ~= container.dup;

    import std.array : array;
    import std.range : iota;

    scope size_t[] p = iota(0, containerLength + 1).array;

    import std.algorithm.mutation : swap;

    size_t i = 1;
    while (i < containerLength)
    {
        p[i]--;
        size_t j = (i % 2 == 1) ? p[i] : 0;

        //extra copying [i] and [j] could be eliminated
        result ~= result[$ - 1].dup;
        swap(result[$ - 1][j], result[$ - 1][i]);

        i = 1;
        while (p[i] == 0)
        {
            p[i] = i;
            i++;
        }
    }
    return result;
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

    assert(permutations([1]) == [[1]]);

    double[][] permDoubleResult = permutations([0.0, 0.0]);
    assert(permDoubleResult.length == 2);
    assert(permDoubleResult[0] == [0, 0]);
    assert(permDoubleResult[1] == [0, 0]);

    int[][] permResult = permutations([1, 2, 3]);

    assert(permResult.length == 6);
    assert(permResult[0] == [1, 2, 3]);
    assert(permResult[1] == [2, 1, 3]);
    assert(permResult[2] == [3, 1, 2]);
    assert(permResult[3] == [1, 3, 2]);
    assert(permResult[4] == [2, 3, 1]);
    assert(permResult[5] == [3, 2, 1]);
}
