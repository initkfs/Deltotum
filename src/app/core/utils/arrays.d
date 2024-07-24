module app.core.utils.arrays;

/**
 * Authors: initkfs
 */
bool drop(T)(ref T[] haystack, T needle)
{
    import std.algorithm.searching : countUntil;
    import std.algorithm.mutation : remove;

    if (haystack.length == 0)
    {
        return false;
    }

    auto pos = haystack.countUntil(needle);
    if (pos == -1)
    {
        return false;
    }

    haystack = haystack.remove(pos);
    return true;
}

unittest
{
    auto origArr = [1, 2, 3, 4];
    auto arr1 = origArr.dup;

    assert(!arr1.drop(5));
    assert(arr1 == origArr);

    assert(arr1.drop(2));
    assert(arr1 == [1, 3, 4]);

    assert(arr1.drop(3));
    assert(arr1.drop(4));
    assert(arr1 == [1]);

    assert(arr1.drop(1));
    assert(arr1 == []);

    assert(!arr1.drop(0));
    assert(!arr1.drop(0));
    assert(arr1 == []);

    void delegate()[] dArr;
    void delegate() dg = () {};
    void delegate() dg1 = () {};
    dArr ~= dg;
    dArr ~= dg1;
    assert(dArr.length == 2);
    assert(dArr.drop(dg));
    assert(dArr == [dg1]);
    assert(dArr.drop(dg1));
    assert(dArr == []);
}
