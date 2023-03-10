module deltotum.math.graphs.edge;

import deltotum.math.graphs.vertex : Vertex;
import deltotum.core.utils.tostring : ToString;

/**
 * Authors: initkfs
 */
class Edge
{
    mixin ToString;

    Vertex src;
    Vertex dest;

    long weight;

    this(Vertex src, Vertex dest)
    {
        import std.exception : enforce;

        enforce(src !is null, "Source vertex must not be null");

        this.src = src;
        this.dest = dest;
    }
}
