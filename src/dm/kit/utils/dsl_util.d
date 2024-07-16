module dm.kit.utils.dsl_util;

// dfmt off
version(DmCtorDsl):
// dfmt on

/**
 * Authors: initkfs
 */
enum DslCtor;

mixin template CtorsJoin(Args...)
{
    enum getStr(alias T) = T.stringof;
    enum getType(alias T) = typeof(T).stringof;

    import std.traits : hasUDA;
    import core.utils.types : hasOverloads;

    static foreach (ctor; __traits(getOverloads, typeof(super), "__ctor"))
    {
        static if (hasUDA!(ctor, DslCtor))
        {
            import std.traits : ParameterIdentifierTuple, Parameters;
            import std.algorithm.iteration : __stdMap = map;
            import std.range : __stdZip = zip;
            import std.array : __stdJoin = join;
            import std.conv : __stdConvText = text;
            import std.meta : __stdStaticMap = staticMap;

            //["a", "b"]
            enum string[] paramsIds = [ParameterIdentifierTuple!ctor];
            //["bool", "double"]
            enum string[] paramsTypes = [
                    __stdStaticMap!(getStr, Parameters!(ctor))
                ];
            //bool a,double b
            enum string paramsByComma = __stdZip(paramsTypes, paramsIds).__stdMap!"a[0] ~ \" \" ~ a[1]".__stdJoin(
                    ",");

            //Rewrite with string interpolation
            //super(a,b)
            enum string callSuper = "super(" ~ paramsIds.__stdJoin(",") ~ ")";
            enum string ctorStart = "@DslCtor this(";

            static if (Args.length > 0)
            {
                //["string", "long"]
                enum string[] thisArgsTypes = [__stdStaticMap!(getType, Args)];
                //["s", "l"]
                enum string[] thisArgsNames = [__stdStaticMap!(getStr, Args)];
                //string s,long l
                enum string thisArgsByComma = __stdZip(thisArgsTypes, thisArgsNames)
                        .__stdMap!"a[0] ~ \" \" ~ a[1]".__stdJoin(
                            ",");

                //this.s=s;
                //this.l=l;
                //this.f=f;
                enum assignThisVars = thisArgsNames.__stdMap!"\"this.\" ~ a ~ \"=\" ~ a ~ \";\"".__stdJoin(
                        "\n");

                /** 
                 * @DslCtor this(string s,long l,bool a,double b) { 
                    super(a,b);
                    this.s=s;
                    this.l=l;
                    } 
                 */
                enum ctorStr = __stdConvText(ctorStart, thisArgsByComma, ",", paramsByComma, ") { \n", callSuper, ";\n", assignThisVars, "\n} ");
            }
            else
            {
                /** 
                 * @DslCtor this(string s,long l,bool a) {
                    super(s,l,a);
                    } 
                 */
                enum ctorStr = __stdConvText(ctorStart, paramsByComma, ") {\n", callSuper, ";\n} ");
            }

            //pragma(msg, ctorStr);
            mixin(ctorStr);
        }

    }
}

unittest
{
    class Foo
    {
        bool a;
        double b;
        this()
        {
        }

        @DslCtor this(bool a, double b)
        {
            this.a = a;
            this.b = b;
        }
    }

    class Bar : Foo
    {
        string s;
        long l;
        this()
        {
        }

        this(string s, long l)
        {
            this.s = s;
            this.l = l;
        }

        mixin CtorsJoin!(s, l) dslCtor;
        alias __ctor = dslCtor.__ctor;
    }

    class Baz : Bar
    {
        ubyte f;
        this(ubyte f)
        {
            this.f = f;
        }

        mixin CtorsJoin!f dslCtor;
        alias __ctor = dslCtor.__ctor;
    }

    // dfmt off
    auto baz = new Baz(
        l : 10, 
        f: 5,
        s: "hello",
        b: 3.0,
        a: true
    );
     // dfmt oт
    assert(baz.l == 10);
    assert(baz.f == 5);
    assert(baz.s == "hello");
    assert(baz.b == 3.0);
    assert(baz.a);

    // static foreach (ctor; __traits(getOverloads, Baz, "__ctor")){
    //     pragma(msg, typeof(ctor));
    // }
}
