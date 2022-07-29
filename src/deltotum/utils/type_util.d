module deltotum.utils.type_util;

import std.traits : isIntegral;

/**
 * Authors: initkfs
 */
mixin template NamedEnum(string enumName, enumMembersNames...)
{
    enum enumMembers = {
        string allMembers = "";
        foreach (name; enumMembersNames)
        {
            allMembers ~= name ~ "=" ~ name.stringof ~ ",";
        }
        return allMembers;
    }();
    mixin("enum " ~ enumName ~ " : string {" ~ enumMembers ~ "}");
}

string eventNameByIndex(E, I)(const I index) @nogc nothrow pure @safe
        if (is(E == enum) && isIntegral!I)
{
    import std.traits : EnumMembers;

    string name = "";
    static foreach (i, member; EnumMembers!E)
    {
        if (i == index)
        {
            name = member.stringof;
        }

    }
    return name;
}

template ChainHierarchy(T)
{
    static if (is(T == class))
    {
        import std.traits : BaseClassesTuple;
        import std.meta: Reverse, AliasSeq;

        alias ChainHierarchy = Reverse!(AliasSeq!(T,
                BaseClassesTuple!T[0 .. $ - 1]));
    }
    else
    {
        alias ChainHierarchy = T;
    }
}

import std.traits : FieldNameTuple;
import std.meta : staticMap;

alias AllFieldNamesTuple(T) = staticMap!(FieldNameTuple, ChainHierarchy!T);
