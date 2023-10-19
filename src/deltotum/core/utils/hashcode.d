module deltotum.core.utils.hashcode;

/**
 * Authors: initkfs
 */
mixin template HashCode(alias HashFunc = object.hashOf)
{
    alias Self = typeof(this);

    //mixin("size_t toHash(this C)() { return " ~ __traits(identifier, hashCode) ~ "; }");

    static if (is(Self == class) && !is(Self == immutable) && !is(Self == shared))
    {
        mixin("override size_t toHash() const nothrow pure @safe { return ", __traits(identifier, hashCode), "; }");
    }
    else
    {
        mixin("size_t toHash() const nothrow pure @safe { return ", __traits(identifier, hashCode), "; }");
    }

    private size_t hashCode() const nothrow pure @safe
    {
        static if (__traits(compiles, super.toHash) && __traits(isOverrideFunction, super
                .toHash))
        {
            size_t hash = super.toHash;
        }
        else
        {
            size_t hash;
        }

        foreach (field; this.tupleof)
        {

            //TODO collision with overflow, null.hashOf == 0, pointers?
            static if (__traits(compiles, field.toHash))
            {
                static if (__traits(compiles, field is null))
                {
                    if (field !is null)
                    {
                        hash += field.toHash;
                    }
                }
                else
                {
                    hash += field.toHash;
                }

            }
            else
            {
                hash += HashFunc(field, hash);
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

    }

    auto c = new C;
    assert(c.toHash == b.toHash);

    class C1 : B
    {
        int i = 3;

        mixin HashCode;
    }

    auto c1 = new C1;
    assert(c.toHash != c1.toHash);

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
