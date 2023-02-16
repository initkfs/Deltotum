module deltotum.core.maths.graphs.graph;

import deltotum.core.maths.graphs.edge : Edge;
import deltotum.core.maths.graphs.vertex : Vertex;

/**
 * Authors: initkfs
 */
class Graph
{
    private
    {
        Edge[][2][Vertex] structure;
        size_t edgeCounter;
    }

    bool addVertex(Vertex vertex)  pure @safe
    {
        import std.exception : enforce;

        enforce(vertex !is null, "Vertex must not be null");

        if (hasVertexUnsafe(vertex))
        {
            return false;
        }

        structure[vertex] = [[], []];

        return true;
    }

    protected bool hasVertexUnsafe(Vertex vertex) nothrow @nogc pure @safe
    {
        return (vertex in structure) !is null;
    }

    bool hasVertex(Vertex vertex) pure @safe
    {
        import std.exception : enforce;

        enforce(vertex !is null, "Vertex must not be null");
        return hasVertexUnsafe(vertex);
    }

    Edge[] getEdgesToVertex(Vertex vertex) pure @safe
    {
        if (!hasVertex(vertex))
        {
            return [];
        }
        return getEdgesToVertexUnsafe(vertex);
    }

    protected Edge[] getEdgesToVertexUnsafe(Vertex vertex) pure @safe
    {
        return structure[vertex][1];
    }

    protected Edge[] getEdgesFromVertexUnsafe(Vertex vertex) pure @safe
    {
        return structure[vertex][0];
    }

    Edge[] getEdgesFromVertex(Vertex vertex) pure @safe
    {
        if (!hasVertex(vertex))
        {
            return [];
        }
        return getEdgesFromVertexUnsafe(vertex);
    }

    bool addEdge(Edge edge)
    {
        import std.exception : enforce;

        enforce(edge !is null, "Edge must not be null");
        enforce(edge.src !is null, "Edge source vertex must not be null");

        Vertex fromVertex = edge.src;
        if (!hasVertexUnsafe(fromVertex))
        {
            if (!addVertex(fromVertex))
            {
                import std.format : format;

                throw new Exception(format("Error adding source vertex %s for edge %s", fromVertex, edge));
            }
        }

        bool isEdgeAdd;

        Vertex toVertex = edge.dest;
        if (toVertex !is null)
        {
            if (!hasVertexUnsafe(toVertex))
            {
                if (!addVertex(toVertex))
                {
                    import std.format : format;

                    throw new Exception(format("Error adding destination vertex %s for edge %s", toVertex, edge));
                }
            }

            import std.algorithm.searching : canFind;

            Edge[] toEdges = getEdgesToVertexUnsafe(toVertex);
            if (!toEdges.canFind(edge))
            {
                structure[toVertex][1] ~= edge;
                isEdgeAdd = true;
            }

        }

        import std.algorithm.searching : canFind;

        Edge[] fromEdges = getEdgesFromVertexUnsafe(fromVertex);
        if (fromEdges.canFind(edge))
        {
            return isEdgeAdd;
        }

        structure[fromVertex][0] ~= edge;
        edgeCounter++;

        return true;
    }

    size_t countVertices() nothrow @nogc pure @safe
    {
        return structure.length;
    }

    size_t countEdges() nothrow @nogc pure @safe
    {
        return edgeCounter;
    }

    bool removeEdge(Edge edge)
    {
        import std.algorithm.searching : countUntil;
        import std.algorithm.mutation : remove;

        Vertex fromVertex = edge.src;
        if (!hasVertex(fromVertex))
        {
            return false;
        }

        bool isRemove;

        auto removeFromPos = getEdgesFromVertexUnsafe(fromVertex).countUntil(edge);
        if (removeFromPos != -1)
        {
            structure[fromVertex][0] = structure[fromVertex][0].remove(removeFromPos);
            isRemove = true;
            edgeCounter--;
        }

        Vertex toVertex = edge.dest;
        if (toVertex !is null)
        {
            auto remooveToPos = getEdgesToVertexUnsafe(toVertex).countUntil(edge);
            if (remooveToPos != -1)
            {
                structure[toVertex][1] = structure[toVertex][1].remove(remooveToPos);
                //isRemove = true;
            }
        }

        return isRemove;
    }

}

unittest
{
    import deltotum.core.maths.graphs.vertex : Vertex;
    import deltotum.core.maths.graphs.edge : Edge;

    Vertex v1 = new Vertex("1");
    Vertex v11 = new Vertex("1");

    Graph graph = new Graph;

    assert(graph.addVertex(v1));
    assert(graph.hasVertex(v1));
    assert(graph.countVertices == 1);
    assert(graph.countEdges == 0);

    assert(!graph.addVertex(v11));
    assert(graph.hasVertex(v11));
    assert(graph.countVertices == 1);
    assert(graph.countEdges == 0);

    Vertex v2 = new Vertex("2");
    Edge e1 = new Edge(v1, v2);
    assert(graph.addEdge(e1));
    assert(!graph.addEdge(e1));
    assert(graph.hasVertex(v2));
    assert(graph.countVertices == 2);
    assert(graph.countEdges == 1);

    Edge e2 = new Edge(v2, v1);
    assert(graph.addEdge(e2));
    assert(graph.countEdges == 2);

    assert(graph.getEdgesFromVertex(v1) == [e1]);
    assert(graph.getEdgesToVertex(v1) == [e2]);
    assert(graph.getEdgesFromVertex(v2) == [e2]);
    assert(graph.getEdgesToVertex(v2) == [e1]);

    assert(graph.removeEdge(e1));
    assert(graph.countEdges == 1);
    assert(graph.getEdgesFromVertex(v1).length == 0);
    assert(graph.getEdgesToVertex(v2).length == 0);
    assert(graph.getEdgesToVertex(v1) == [e2]);
    assert(graph.getEdgesFromVertex(v2) == [e2]);
}
