module dm.core.utils.factories;

/**
 * Authors: initkfs
 */

class FactoryKit(Entity, Type = string)
{
    private
    {
        Entity delegate()[Type] factories;
    }

    this(scope void delegate(
            scope void delegate(Type, Entity delegate()) @safe
    ) @safe factoriesProvider) @safe
    {
        factoriesProvider((type, Entity delegate() entityFactory) {
            factories[type] = entityFactory;
        });
    }

    Entity create(Type type)
    {
        return factory(type)();
    }

    Entity delegate() factory(Type type)
    {
        if (!has(type))
        {
            import std.conv : to;

            throw new Exception("Not found factory for type " ~ type.to!string);
        }
        return factories[type];
    }

    bool has(Type type) const pure @safe
    {
        return (type in factories) !is null;
    }

}

unittest
{

    enum Ftype
    {
        a,
        b,
    }

    class A
    {
    }

    class B
    {
    }

    auto fk = new FactoryKit!(Object, Ftype)((builder) {
        builder(Ftype.a, () => new A);
        builder(Ftype.b, () => new B);
    });

    assert(cast(A)(fk.create(Ftype.a)));
    assert(cast(B)(fk.create(Ftype.b)));
}
