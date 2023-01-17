module deltotum.utils.tostring;

/**
 * Authors: initkfs
 */
mixin template ToString()
{
    alias Self = typeof(this);

    mixin("string toString(this C)() { return " ~ __traits(identifier, toStringImpl) ~ "!C; }");

    private string toStringImpl(C)()
    {
        import deltotum.utils.type_util;
        import std.conv : to;

        static if (is(C == class))
        {
            string result = C.classinfo.name;

            import std.string : lastIndexOf;

            const lastModuleDotPos = result.lastIndexOf('.');
            if (lastModuleDotPos != -1)
            {
                result = result[lastModuleDotPos + 1 .. $];
            }
        }
        else
        {
            string result = __traits(identifier, C);
        }

        result ~= "{";

        enum fields = AllFieldNamesTuple!C;
        enum fieldsCount = fields.length;

        import std.traits : isDelegate, hasUDA, isPointer;
        import deltotum.application.components.uni.attribute.attributes : Service;

        static foreach (i, fieldName; fields)
        {
            {
                alias field = __traits(getMember, C, fieldName);
                auto fieldValue = __traits(getMember, cast(C) this, fieldName);
                alias fieldType = typeof(fieldValue);
                //TODO filter or ToStringExclude...?
                //TODO check alias with __traits(compiles, hasUDA!(member, attribute)
                static if (!isDelegate!fieldType && !hasUDA!(field, Service))
                {
                    static if (isPointer!fieldType)
                    {
                        result ~= fieldName ~ ":*" ~ to!string(*fieldValue);
                    }
                    else
                    {
                        result ~= fieldName ~ ":" ~ to!string(fieldValue);
                    }

                    static if (fieldsCount > 0 && i < fieldsCount - 1)
                    {
                        result ~= ",";
                    }
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
        string s1 = "string1";
    }

    B b = new B;
    assert(b.toString == "B{i:1,d:2,s:string,s1:string1}");

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
