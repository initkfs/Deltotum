module deltotum.core.math.combinatorics;

/**
 * Authors: initkfs
 */
class Combinatorics
{
    double combinationsMfromN(double m, double n) const pure @nogc nothrow
    {
        if (m >= n)
        {
            return 0;
        }
        import deltotum.core.math.math : Math;

        return Math.factorial(n) / (Math.factorial(m) * Math.factorial(n - m));
    }

    double permutations(double n) const pure @nogc nothrow
    {
        import deltotum.core.math.math : Math;

        return Math.factorial(n);
    }

    double permutationsMofN(double m, double n) const pure @nogc nothrow
    {
        if(m >= n){
            return 0;
        }
        import deltotum.core.math.math : Math;

        return Math.factorial(n) / Math.factorial(n - m);
    }
}

unittest
{
    auto comb = new Combinatorics;

    import std.math.operations : isClose;

    assert(comb.combinationsMfromN(3, 9) == 84);
    assert(isClose(comb.permutations(9), 362_880));
    assert(isClose(comb.permutationsMofN(3, 9), 504));
}
