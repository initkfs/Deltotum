module deltotum.core.maths.sets.marked_hash_set;

/**
 * Authors: initkfs
 */
class MarkedHashSet(T)
{
    private
    {
        bool[T] store;
    }

    //for immutability
    this(T[] safeValues...) pure
    {
        //without calling the virtual method in the constructor
        foreach (v; safeValues)
        {
            store[v] = false;
        }
        store.rehash;
    }

    bool add(T value, bool isMarked = false) @safe
    {
        static if (__traits(compiles, value is null))
        {
            import std.exception : enforce;

            enforce(value !is null, "Value must not be null");
        }

        if (contains(value))
        {
            return false;
        }
        store[value] = isMarked;
        return true;
    }

    bool addAll(T[] values)
    {
        if (values.length == 0)
        {
            return false;
        }

        bool isAdd = true;
        foreach (v; values)
        {
            isAdd &= add(v);
        }

        store.rehash;

        return isAdd;
    }

    bool addAll(T[] values...)
    {
        return addAll(values);
    }

    bool contains(T element) const @nogc nothrow pure @safe
    {
        return (element in store) !is null;
    }

    bool mark(T element) @safe
    {
        if (!contains(element))
        {
            return false;
        }
        auto result = store[element] = true;
        return result;
    }

    size_t length() const @nogc nothrow pure @safe
    {
        return store.length;
    }

    T[] toArray() const nothrow pure @safe
    {
        return store.keys;
    }

    int opApply(scope int delegate(ref T) @safe dg) const scope @safe
    {
        foreach (k; store.byKey)
        {
            if (const result = dg(k))
            {
                return result;
            }
        }
        return 0;
    }

    void onUnionWith(MarkedHashSet!T other, void delegate(ref T) @safe dg) const @safe
    {
        foreach (v; store.byKey)
        {
            dg(v);
        }

        foreach (v2; other)
        {
            if (!contains(v2))
            {
                dg(v2);
            }
        }
    }

    //A ∪ B 
    MarkedHashSet!T unionWith(MarkedHashSet!T other) const
    {
        auto result = new MarkedHashSet!T;
        onUnionWith(other, (ref T e) { result.add(e); });
        return result;
    }

    //A ∩ B
    void onIntersetion(MarkedHashSet!T other, void delegate(ref T) @safe dg) const @safe
    {
        //A ∩ ∅ = ∅ 
        foreach (v2; other)
        {
            if (contains(v2))
            {
                dg(v2);
            }
        }
    }

    MarkedHashSet!T intersection(MarkedHashSet!T other) const
    {
        auto result = new MarkedHashSet!T;
        onIntersetion(other, (ref T e) { result.add(e); });
        return result;
    }

    //A ∖ B
    void onDifference(MarkedHashSet!T other, void delegate(ref T) @safe dg) const @safe
    {
        foreach (v; store.byKey)
        {
            if (!other.contains(v))
            {
                dg(v);
            }
        }
    }

    MarkedHashSet!T difference(MarkedHashSet!T other) const
    {
        auto result = new MarkedHashSet!T;
        onDifference(other, (ref T e) { result.add(e); });

        return result;
    }

    void onSymmetricDifference(MarkedHashSet!T other, void delegate(ref T) @safe dg) const @safe
    {
        foreach (v; store.byKey)
        {
            if (!other.contains(v))
            {
                dg(v);
            }
        }
        foreach (v2; other)
        {
            if (!contains(v2))
            {
                dg(v2);
            }
        }
    }

    MarkedHashSet!T symmetricDifference(MarkedHashSet!T other) const
    {
        auto result = new MarkedHashSet!T;
        onSymmetricDifference(other, (ref T e) { result.add(e); });
        return result;
    }

    //A ⊂ B
    bool isSubsetOf(MarkedHashSet!T other) const @safe
    {
        //TODO empty sets, >=?
        if (length > other.length)
        {
            return false;
        }
        foreach (v; store.byKey)
        {
            if (!other.contains(v))
            {
                return false;
            }
        }
        return true;
    }

    bool isSupersetOf(MarkedHashSet!T other) @safe
    {
        return other.isSubsetOf(this);
    }

    override size_t toHash() const nothrow @trusted
    {
        import std.exception : collectException;

        try
        {
            size_t hash = store.hashOf;
            return hash;
        }
        catch (Exception e)
        {
            throw new Error("Hash calculation error", e);
        }
    }

    override bool opEquals(Object other) const
    {
        if (other is null)
        {
            return false;
        }

        if (other is this)
        {
            return true;
        }

        auto set = cast(typeof(this)) other;
        if (set is null || set.length != length)
        {
            return false;
        }

        foreach (otherValue; set)
        {
            if (!contains(otherValue))
            {
                return false;
            }
        }

        return true;
    }
}

unittest
{
    immutable class A
    {
        bool opEquals(in A other) const
        {
            return this is other;
        }

        int toHash() const
        {
            return 0;
        }
    }

    immutable class B : A
    {
    }

    auto a = new A;
    immutable set = new MarkedHashSet!A([a, a]);
    assert(set.length == 1);
    assert(set.contains(a));
    assert(!set.contains(new B));
    assert(set.toArray == [a]);
}

unittest
{
    auto a = new MarkedHashSet!int([1, 2, 3]);
    auto b = new MarkedHashSet!int([1, 4]);

    //a ∪ b
    auto unionAB = a.unionWith(b);
    assert(unionAB.length == 4);
    assert(unionAB == new MarkedHashSet!int([1, 2, 3, 4]));
    assert(unionAB == new MarkedHashSet!int([4, 3, 2, 1]));
    assert(unionAB != new MarkedHashSet!int([1, 2, 3]));

    //a ∪ ∅ == a
    assert(a.unionWith(new MarkedHashSet!int) == a);
}

unittest
{
    auto a = new MarkedHashSet!(int)([1, 2, 3, 4]);
    auto b = new MarkedHashSet!(int)([1, 5, 2]);

    auto intersectAB = a.intersection(b);
    assert(intersectAB.length == 2);
    assert(intersectAB == new MarkedHashSet!int([1, 2]));

    //a ∩ ∅ == ∅
    assert(a.intersection(new MarkedHashSet!int) == new MarkedHashSet!int);
}

unittest
{
    auto a = new MarkedHashSet!(int)([1, 2, 3, 4]);
    auto b = new MarkedHashSet!(int)([1, 2]);

    auto diffAB = a.difference(b);
    assert(diffAB.length == 2);
    assert(diffAB == new MarkedHashSet!int([3, 4]));

    //a ∩ a == ∅
    assert(a.difference(a) == new MarkedHashSet!int);
}

unittest
{
    auto a = new MarkedHashSet!(int)([1, 2, 3, 4]);
    auto b = new MarkedHashSet!(int)([1, 2, 6]);

    auto symmDiffAB = a.symmetricDifference(b);
    assert(symmDiffAB.length == 3);
    assert(symmDiffAB == new MarkedHashSet!int([3, 4, 6]));

    assert(a.symmetricDifference(new MarkedHashSet!int) == a);
}
