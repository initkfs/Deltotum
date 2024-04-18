module dm.core.utils.type_util;

import std.format : format;
import std.algorithm.iteration : map;
import std.array : join;
import std.meta : allSatisfy;
import std.traits : isSomeString, isSomeChar, isIntegral, Unqual;

/**
 * Authors: initkfs
 */
enum hasOverloads(alias type, string symbol) = __traits(getOverloads, type, symbol).length != 0;

enum isNamedEnumValidMemberName(alias T) = isSomeString!(typeof(T));

mixin template NamedStrEnum(string enumName, enumMembersNames...)
        if (allSatisfy!(isNamedEnumValidMemberName, enumMembersNames))
{
    mixin(
        "enum ", enumName, " : string { ",
        [enumMembersNames].map!(name => format("%s=\"%s\"", name, name)).join(","),
        " }");
}

@safe unittest
{
    mixin NamedStrEnum!("En", "a", "b");
    enum a = En.a;
    assert(a == "a");
    enum b = En.b;
    assert(b == "b");
}

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
