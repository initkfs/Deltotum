module api.dm.addon.math.graphs.edge;

import api.dm.addon.math.graphs.vertex : Vertex;

/**
 * Authors: initkfs
 */
class Edge
{
    Vertex src;
    Vertex dest;

    double weight = 0;

    this(Vertex src, Vertex dest) pure @safe
    {
        if (!src)
        {
            throw new Exception("Source vertex must not be null");
        }

        if (!dest)
        {
            throw new Exception("Destination vertex must not be null");
        }

        if ((cast(const(Vertex)) src).opEquals(cast(const(Vertex)) dest))
        {
            throw new Exception("Source vertex must not be destination");
        }

        this.src = src;
        this.dest = dest;
    }

    override bool opEquals(Object o) const => opEquals(cast(const(Edge)) o);
    bool opEquals(const Edge other) const @safe nothrow
    {
        if (!other)
        {
            return false;
        }
        return other.src == src && other.dest == dest && other.weight == weight;
    }

    override size_t toHash() const pure nothrow
    {
        size_t hash = weight.hashOf;
        hash = src.toHash.hashOf(hash);
        if (dest)
        {
            hash = dest.toHash.hashOf(hash);
        }
        return hash;
    }

    override string toString() const
    {
        import std.format : format;

        return format("%s(src: %s, dest: %s)", this.classinfo.name, src, dest);
    }
}

unittest
{
    import std.exception : assertThrown;

    assertThrown(new Edge(null, null));
    assertThrown(new Edge(null, new Vertex(1)));
    assertThrown(new Edge(new Vertex(1), null));
    assertThrown(new Edge(new Vertex(1), new Vertex(1)));

    auto v1 = new Vertex(1);
    auto v2 = new Vertex(2);

    auto edgeSrcDest = new Edge(v1, v2);
    auto edgeSrcDest2 = new Edge(v1, v2);
    assert(edgeSrcDest == edgeSrcDest2);

    auto edgeDestSrc = new Edge(v2, v1);
    assert(edgeSrcDest != edgeDestSrc);
}
