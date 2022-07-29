module deltotum.utils.equals_other;

/**
 * Authors: initkfs
 */
//TODO Object.opEquals is not shared
mixin template EqualsOther()
{
    alias Self = typeof(this);

    import std.traits : CopyTypeQualifiers, isImplicitlyConvertible, fullyQualifiedName;

    static if (is(Self == class))
    {
        alias Other = Object;
    }
    else
    {
        alias Other = Self;
    }

    alias CopyTypeQualifiers!(Self, Other) OtherType;
    static if (is(Self == class))
    {
        enum opEqualsParameter = fullyQualifiedName!OtherType;
    }
    else
    {
        enum opEqualsParameter = __traits(identifier, OtherType);
    }

    import std.format : format;

    // enum opEqualsSignature = format("bool opEquals(%s other) @safe { return %s(other); }", opEqualsParameter, __traits(
    //             identifier, equalsOther));

    // static if (is(Self == class) && isImplicitlyConvertible!(Other, OtherType))
    // {
    //     mixin("override " ~ opEqualsSignature);
    // }
    // else
    // {
    //     mixin(opEqualsSignature);
    // }

    enum opEqualsSignature = format("bool opEquals(this C)(%s other) @safe { return %s!(C, %s)(other); }", opEqualsParameter, __traits(
                identifier, equalsOther), opEqualsParameter);
    mixin(opEqualsSignature);

    private bool equalsOther(C, T)(T other) @safe
    {
        static if (is(T == class))
        {
            if (other is null)
            {
                return false;
            }

            if (this is other)
            {
                return true;
            }

            // static if (__traits(compiles, super.opEquals) && __traits(isOverrideFunction, super
            //         .opEquals))
            // {
            //     if (!super.opEquals(other))
            //     {
            //         return false;
            //     }
            // }

            auto otherType = cast(C) other;
            if (!otherType)
            {
                return false;
            }
        }

        import deltotum.utils.type_util : AllFieldNamesTuple;

        static foreach (field; AllFieldNamesTuple!(C))
        {
            //TODO pointers, etc?
            static if (is(C == class))
            {
                mixin(`if (` ~ field ~ `!= ` ~ __traits(identifier, otherType) ~ `.` ~ field ~ `) return false;`);
            }
            else
            {
                mixin(`if (` ~ field ~ `!= ` ~ __traits(identifier, other) ~ `.` ~ field ~ `) return false;`);
            }
        }

        return true;
    }
}

unittest
{
    class A
    {
        mixin EqualsOther;

        string s = "s";
        int i = 65;
    }

    auto a1 = new A;
    auto a2 = new A;
    assert(a1 == a1);
    assert(a2 == a2);
    assert(a1 == a2);
    assert(a2 == a1);

    a2.i = 0;
    assert(a1 != a2);

    class B
    {
        mixin EqualsOther;
        A a;

        this()
        {
            a = new A;
        }
    }

    auto b = new B;
    assert(b.a == a1);
    assert(b.a != a2);

    auto b1 = new B;
    assert(b == b1);
    b1.a.i = 0;
    assert(b != b1);

    class B1 : B
    {
        mixin EqualsOther;
    }

    auto b11 = new B1;
    assert(b11 == new B1);

    immutable class C
    {
        mixin EqualsOther;
        string s = "string";
        int i = 5;
    }

    auto c1 = new C;
    auto c2 = new C;
    assert(c1 == c2);

    const class D
    {
        mixin EqualsOther;
        int i = 7;
    }

    assert(new D == new D);
}

// unittest
// {
//     struct S
//     {
//         mixin EqualsOther;
//         string s = "string";
//         int i = 4;
//     }

//     S s;
//     S s1;
//     assert(s == s1);

//     immutable struct SI
//     {
//         mixin EqualsOther;
//         string s = "string";
//     }

//     SI si;
//     SI si1;
//     assert(si == si1);

//     const struct SC
//     {
//         mixin EqualsOther;
//         int i = 0;
//     }

//     SC sc;
//     SC sc1;
//     assert(sc == sc1);

//     shared struct SH
//     {
//         mixin EqualsOther;
//         int i = 0;
//     }

//     SH sh;
//     SH sh1;
//     assert(sh == sh1);
// }
