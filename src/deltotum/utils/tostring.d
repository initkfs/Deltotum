module deltotum.utils.tostring;

/**
 * Authors: initkfs
 */
mixin template ToString()
{
    alias Self = typeof(this);

    static if (is(Self == class) && !is(Self == immutable) && !is(Self == shared))
    {
        mixin("override string toString() pure @safe { return " ~ __traits(identifier, toStringImpl) ~ "; }");
    }
    else
    {
        mixin("string toString() pure @safe { return " ~ __traits(identifier, toStringImpl) ~ "; }");
    }

    private string toStringImpl(this C)() pure @safe
    {
        import std.traits : FieldNameTuple;
        import std.conv : to;

        static if (is(Self == class))
        {
            string result = C.classinfo.name;

            import std.string : lastIndexOf;
            const lastModuleDotPos = result.lastIndexOf('.');
            if(lastModuleDotPos != -1){
                result = result[lastModuleDotPos + 1 .. $];
            }
        }
        else
        {
            string result = __traits(identifier, Self);
        }

        result ~= "{";
        static if (__traits(compiles, super.toString) && __traits(isOverrideFunction, super
                .toString))
        {
            result ~= super.toString ~ " ";
        }

        enum fields = FieldNameTuple!(typeof(this));
        enum fieldsCount = fields.length;
        static foreach (i, field; fields)
        {
            {
                auto fieldValue = __traits(getMember, this, field);
                result ~= field ~ ":" ~ to!string(fieldValue);
                static if (fieldsCount > 0 && i < fieldsCount - 1)
                {
                    result ~= ",";
                }
            }
        }
        result ~= "}";
        return result;
    }
}

unittest
{
    class A
    {
        mixin ToString;
        int i = 1;
        double d = 2;
        string s = "string";
    }

    A a = new A;
    assert(a.toString == "A{i:1,d:2,s:string}");

    class B : A
    {
        mixin ToString;
        string s1 = "string1";
    }

    B b = new B;
    assert(b.toString == "B{A{i:1,d:2,s:string} s1:string1}");

    immutable class C
    {
        mixin ToString;
        string s = "string";
    }

    assert((new C).toString.length > 0);

    shared class S
    {
        mixin ToString;
        string s = "string";
    }

    assert((new S).toString.length > 0);

    immutable shared class IS
    {
        mixin ToString;
        string s = "string";
    }

    assert((new IS).toString.length > 0);
}

unittest
{
    struct A
    {
        mixin ToString;
        int i = 1;
        double d = 2;
        string s = "string";
    }

    A a;
    assert(a.toString == "A{i:1,d:2,s:string}");
}
