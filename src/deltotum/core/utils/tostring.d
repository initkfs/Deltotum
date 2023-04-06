module deltotum.core.utils.tostring;

enum ToStringExclude;

/**
 * Authors: initkfs
 */
mixin template ToString()
{
    alias Self = typeof(this);

    mixin("string toString(this C)() { return " ~ __traits(identifier, toStringImpl) ~ "!C; }");

    private string toStringImpl(C)()
    {
        import deltotum.core.utils.type_util;
        import std.conv : to;

        static if (is(C == class))
        {
            string result = this.classinfo.name;

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
        import deltotum.core.applications.components.uni.attributes : Service;
        import deltotum.core.utils.meta : hasOverloads;
        import deltotum.core.utils.tostring : ToStringExclude;

        static foreach (i, fieldName; fields)
        {
            {
                alias field = __traits(getMember, C, fieldName);
                auto fieldValue = __traits(getMember, cast(C) this, fieldName);
                alias fieldType = typeof(fieldValue);
                //TODO filter or ToStringExclude...?
                //TODO check alias with __traits(compiles, hasUDA!(member, attribute)
                //TODO replace hasUDA for overloads
                static if (!isDelegate!fieldType && !hasOverloads!(typeof(cast(C) this), fieldName) && !hasUDA!(field, Service) && !hasUDA!(
                        field, ToStringExclude))
                {
                    static if (isPointer!fieldType)
                    {
                        result ~= fieldName ~ ":*" ~ (fieldValue is null ? "null" : to!string(
                                *fieldValue));
                    }
                    else if (is(fieldType == Self))
                    {
                        result ~= fieldName ~ ":(this)" ~ Self.stringof;
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
