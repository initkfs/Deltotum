module deltotum.utils.hashcode;

/**
 * Authors: initkfs
 */
mixin template HashCode(alias HashFunc = object.hashOf)
{
    alias Self = typeof(this);

    static if (is(Self == class) && !is(Self == immutable) && !is(Self == shared))
    {
        mixin("override size_t toHash(){ return " ~ __traits(identifier, hashCode) ~ "; }");
    }
    else
    {
        mixin("size_t toHash() { return " ~ __traits(identifier, hashCode) ~ "; }");
    }

    private size_t hashCode() nothrow @safe
    {
        import std.traits : FieldNameTuple;

        static if (__traits(compiles, super.toHash) && __traits(isOverrideFunction, super
                .toHash))
        {
            size_t hash = super.toHash;
        }
        else
        {
            size_t hash;
        }

        static foreach (field; FieldNameTuple!(typeof(this)))
        {
            {
                //null.hashOf == 0
                auto fieldValue = __traits(getMember, this, field);
                static if (__traits(compiles, fieldValue.toHash) && __traits(compiles, fieldValue is null))
                {
                    if (fieldValue !is null)
                    {
                        hash += fieldValue.toHash;
                    }
                }
                else
                {
                    hash = HashFunc(fieldValue, hash);
                }
            }
        }
        return hash;
    }
}

unittest
{
    class A
    {
        mixin HashCode;
        int i = 1;
        double d = 2;
        string s = "string";
    }

    auto a1 = new A;
    auto a2 = new A;
    assert(a1.toHash == a2.toHash);

    class B
    {
        mixin HashCode;
        int i2 = 1;
        double d2 = 2;
        string s2 = "string";
    }

    auto b = new B;
    assert(a1.toHash == b.toHash);

    class C : B
    {
        mixin HashCode;
        int i = 3;
    }

    auto c = new C;
    assert(c.toHash > 0);

    immutable class I
    {
        mixin HashCode;
        int i = 0;
    }

    auto i = new I;
    assert(i.toHash > 0);

    const class D
    {
        mixin HashCode;
        int i = 0;
    }

    auto d = new D;
    assert(d.toHash > 0);

    shared immutable class S
    {
        mixin HashCode;
        int i = 0;
    }

    auto s = new S;
    assert(s.toHash > 0);
}

unittest
{
    struct A
    {
        mixin HashCode;
        int i = 1;
        double d = 2;
        string s = "string";
    }

    A* a1 = new A;
    A* a2 = new A;
    assert(a1.toHash == a2.toHash);
}
