module api.math.graphs.vertex;

/**
 * Authors: initkfs
 */
class Vertex
{
    string id;

    this(string id) pure @safe
    {
        assert(id.length != 0);
        this.id = id;
    }

    this(const(string) id) const pure @safe
    {
        assert(id.length != 0);
        this.id = id;
    }

    this(string id) immutable pure @safe
    {
        assert(id.length != 0);
        this.id = id;
    }

    override bool opEquals(Object o) const => opEquals(cast(const(Vertex)) o);
    bool opEquals(const Vertex other) const @safe nothrow pure => (other && other.id == id);

    override size_t toHash() const pure nothrow
    {
        size_t hash = id.hashOf;
        return hash;
    }
}

unittest
{
    auto v1 = new Vertex("1");
    auto v11 = new Vertex("1");
    assert(v1 == v11);

    const vc1 = new const Vertex("1");
    assert(v1 == vc1);

    immutable vi1 = new immutable Vertex("1");
    assert(v1 == vi1);

    auto v2 = new Vertex("2");
    assert(v1 != v2);
    assert(vc1 != v2);
    assert(vi1 != v2);

    bool[const Vertex] aa;
    aa[v1] = true;
    assert(v1 in aa);
    assert(vc1 in aa);
    assert(vi1 in aa);

    assert(aa[v1]);
    assert(aa[vc1]);
    assert(aa[vi1]);
}
