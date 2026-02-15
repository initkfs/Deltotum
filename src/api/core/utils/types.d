module api.core.utils.types;

import std.format : format;
import std.algorithm.iteration : map;
import std.array : join;
import std.meta : allSatisfy;
import std.traits : isSomeString, isSomeChar, isIntegral, Unqual;

/**
 * Authors: initkfs
 */
enum hasOverloads(alias type, string symbol) = __traits(getOverloads, type, symbol).length != 0;

string enumNameByIndex(E)(size_t index = 0) if (is(E == enum))
{
    import std.traits : EnumMembers;

    static foreach (i, member; EnumMembers!E)
    {
        if (i == index)
            return member.stringof;
    }

    import std.format : format;

    throw new Exception(format("Not found enum member with index %s for enum %s", index, E.stringof));
}

unittest
{
    import std.exception : assertThrown;

    const shared enum Foo
    {
        a,
        b
    }

    assert(enumNameByIndex!Foo(0) == "a");
    assert(enumNameByIndex!Foo(1) == "b");
    assertThrown(enumNameByIndex!Foo(2));

    enum Bar
    {
        a = "aa",
        b = "bb"
    }

    assert(enumNameByIndex!Bar(0) == "a");
    assert(enumNameByIndex!Bar(1) == "b");
}

template ChainHierarchy(T)
{
    static if (is(T == class))
    {
        import std.traits : BaseClassesTuple;
        import std.meta : Reverse, AliasSeq;

        alias ChainHierarchy = Reverse!(AliasSeq!(T,
                BaseClassesTuple!T[0 .. $ - 1]));
    }
    else
    {
        alias ChainHierarchy = T;
    }
}

unittest
{
    immutable class A
    {
    }

    immutable class B : A
    {
    }

    immutable class C : B
    {
    }

    import std.meta : AliasSeq;

    alias ch = ChainHierarchy!C;
    assert(is(ch == AliasSeq!(A, B, C)));
}

import std.traits : FieldNameTuple;
import std.meta : staticMap;

alias AllFieldNamesTuple(T) = staticMap!(FieldNameTuple, ChainHierarchy!T);

auto castSafe(To, From)(From target)
{
    import std.traits : CopyTypeQualifiers;

    return cast(CopyTypeQualifiers!(typeof(target), To)) target;
}

unittest
{
    class Foo
    {
    }

    class Bar : Foo
    {
    }

    class Baz
    {
    }

    auto bar = new Bar;
    assert(bar.castSafe!Bar == bar);
    assert(bar.castSafe!Foo == bar);
    assert(bar.castSafe!Object == bar);
    assert(bar.castSafe!Baz is null);

    import std.traits : isMutable;

    const cbar = new Bar;
    assert(!isMutable!(typeof(cbar.castSafe!Foo)));
}