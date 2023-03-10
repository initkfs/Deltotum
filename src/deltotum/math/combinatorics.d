module deltotum.math.combinatorics;

/**
 * Authors: initkfs
 */
size_t permutationCount(size_t count) pure @nogc nothrow
{
    if (count == 0)
    {
        return 0;
    }
    import math = deltotum.math.math;

    return math.factorial(count);
}

size_t permutationCountMfromN(size_t m, size_t n) pure @nogc nothrow
{
    if (m == 0 || n == 0 || m >= n)
    {
        return 0;
    }
    import math = deltotum.math.math;

    return math.factorial(n) / math.factorial(n - m);
}

/** 
 * https://www.quickperm.org
 */
T[][] permutation(T)(in T[] container) pure nothrow @safe if (!is(T == void))
{
    typeof(return) result;
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

size_t combinationCountMfromN(size_t m, size_t n) pure @nogc nothrow
{
    if (m == 0 || n == 0 || m >= n)
    {
        return 0;
    }
    import math = deltotum.math.math;

    return math.factorial(n) / (math.factorial(m) * math.factorial(n - m));
}

/** 
 * https://rosettacode.org/wiki/Combinations#D
 */
T[][] combination(T)(in T[] container, size_t byCount) pure nothrow @safe
        if (!is(T == void))
{
    if (byCount == 0)
    {
        //base case for recursion
        return [[]];
    }

    if (byCount == container.length)
    {
        return [container.dup];
    }

    typeof(return) result;

    immutable containerLength = container.length;
    if (containerLength == 0 || byCount > containerLength)
    {
        return result;
    }

    foreach (i, element; container)
    {
        foreach (tail; container[i + 1 .. $].combination(byCount - 1))
        {
            result ~= element ~ tail;
        }
    }

    return result;
}

unittest
{
    assert(permutationCount(0) == 0);
    assert(permutationCount(9) == 362_880);

    assert(permutationCountMfromN(0, 0) == 0);
    assert(permutationCountMfromN(0, 1) == 0);
    assert(permutationCountMfromN(1, 0) == 0);
    assert(permutationCountMfromN(3, 9) == 504);
    assert(permutationCountMfromN(9, 3) == 0);

    assert(permutation([1]) == [[1]]);

    double[][] permDoubleResult = permutation([0.0, 0.0]);
    assert(permDoubleResult.length == 2);
    assert(permDoubleResult[0] == [0, 0]);
    assert(permDoubleResult[1] == [0, 0]);

    int[][] permResult = permutation([1, 2, 3]);

    assert(permResult.length == 6);
    assert(permResult[0] == [1, 2, 3]);
    assert(permResult[1] == [2, 1, 3]);
    assert(permResult[2] == [3, 1, 2]);
    assert(permResult[3] == [1, 3, 2]);
    assert(permResult[4] == [2, 3, 1]);
    assert(permResult[5] == [3, 2, 1]);

    assert(combinationCountMfromN(0, 0) == 0);
    assert(combinationCountMfromN(0, 1) == 0);
    assert(combinationCountMfromN(1, 0) == 0);
    assert(combinationCountMfromN(3, 9) == 84);
    assert(combinationCountMfromN(9, 3) == 0);

    assert(combination([0], 0) == [[]]);
    assert(combination([1, 2], 0) == [[]]);
    assert(combination([1, 2], 10) == []);

    auto comb1to3by2 = [1, 2, 3].combination(2);
    assert(comb1to3by2.length == 3);
    assert(comb1to3by2[0] == [1, 2]);
    assert(comb1to3by2[1] == [1, 3]);
    assert(comb1to3by2[2] == [2, 3]);

    assert([1, 2, 3].combination(3) == [[1, 2, 3]]);

    auto comb1to4by3 = [1, 2, 3, 4].combination(3);
    assert(comb1to4by3.length == 4);
    assert(comb1to4by3[0] == [1, 2, 3]);
    assert(comb1to4by3[1] == [1, 2, 4]);
    assert(comb1to4by3[2] == [1, 3, 4]);
    assert(comb1to4by3[3] == [2, 3, 4]);
}
