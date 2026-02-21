module api.core.utils.types;

/**
 * Authors: initkfs
 */

struct ProviderFactory(T)
{
    T delegate() getNew;
    void delegate(scope void delegate(T) onT) getNewScoped;

    this(T delegate() getNewProvider, void delegate(scope void delegate(T)) getNewScopeProvider) pure @safe
    {
        if (!getNewProvider)
        {
            throw new Exception("ProviderFactory must not be null");
        }

        if (!getNewScopeProvider)
        {
            throw new Exception("Scope provider must not be null");
        }
        this.getNew = getNewProvider;
        this.getNewScoped = getNewScopeProvider;
    }
}

enum hasOverloads(alias type, string symbol) = __traits(getOverloads, type, symbol).length != 0;

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
