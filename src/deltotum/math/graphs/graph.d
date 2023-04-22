module deltotum.math.graphs.graph;

import deltotum.math.graphs.edge : Edge;
import deltotum.math.graphs.vertex : Vertex;

import std.typecons : Nullable;

/**
 * Authors: initkfs
 */
class Graph
{
    private
    {
        Edge[][Vertex] graph;
        size_t edgeCounter;
    }

    bool addVertex(Vertex vertex) pure @safe
    {
        import std.exception : enforce;

        enforce(vertex !is null, "Vertex must not be null");

        if (hasVertexUnsafe(vertex))
        {
            return false;
        }

        return addVertexUnsafe(vertex);
    }

    bool addVertexUnsafe(Vertex vertex) pure @safe
    {
        graph[vertex] = [];
        return true;
    }

    protected bool hasVertexUnsafe(Vertex vertex) nothrow @nogc pure @safe
    {
        return (vertex in graph) !is null;
    }

    bool hasVertex(Vertex vertex) pure @safe
    {
        import std.exception : enforce;

        enforce(vertex !is null, "Vertex must not be null");
        return hasVertexUnsafe(vertex);
    }

    void onEdgeForVertex(Vertex vertex, scope bool delegate(Edge) @safe onEdge) @safe
    {
        if (!hasVertex(vertex))
        {
            return;
        }
        auto edges = graph[vertex];
        foreach (edge; edges)
        {
            if (!onEdge(edge))
            {
                return;
            }
        }
    }

    Nullable!(Edge[]) getEdgesForVertex(Vertex vertex) pure @safe
    {
        if (!hasVertex(vertex))
        {
            return Nullable!(Edge[]).init;
        }
        auto edges = graph[vertex];
        return Nullable!(Edge[])(edges);
    }

    void onEdgesToVertex(Vertex vertex, scope bool delegate(Edge) @safe onEdge) @safe
    {
        onEdgeForVertex(vertex, (Edge edge) {
            if (edge.dest == vertex)
            {
                return onEdge(edge);
            }
            return true;
        });
    }

    Edge[] getEdgesToVertex(Vertex vertex) @safe
    {
        Edge[] edges;
        onEdgesToVertex(vertex, (Edge edge) { edges ~= edge; return true; });
        return edges;
    }

    void onEdgesFromVertex(Vertex vertex, scope bool delegate(Edge) @safe onEdge) @safe
    {
        onEdgeForVertex(vertex, (edge) {
            if (edge.src == vertex)
            {
                return onEdge(edge);
            }
            return true;
        });
    }

    Edge[] getEdgesFromVertex(Vertex vertex)
    {
        Edge[] edges;
        onEdgesFromVertex(vertex, (Edge edge) { edges ~= edge; return true; });
        return edges;
    }

    bool addEdge(Edge edge)
    {
        import std.exception : enforce;

        enforce(edge !is null, "Edge must not be null");
        enforce(edge.src !is null, "Edge source vertex must not be null");

        Vertex fromVertex = edge.src;
        if (!hasVertexUnsafe(fromVertex))
        {
            if (!addVertexUnsafe(fromVertex))
            {
                import std.format : format;

                throw new Exception(format("Error adding source vertex %s for edge %s", fromVertex, edge));
            }
        }

        bool isEdgeAdd;

        Vertex destVertex = edge.dest;
        if (destVertex !is null)
        {
            if (!hasVertexUnsafe(destVertex))
            {
                if (!addVertexUnsafe(destVertex))
                {
                    import std.format : format;

                    throw new Exception(format("Error adding destination vertex %s for edge %s", destVertex, edge));
                }
            }

            import std.algorithm.searching : canFind;

            auto mustBeAllDestEdges = getEdgesForVertex(destVertex);
            if (!mustBeAllDestEdges.isNull)
            {
                auto allDestEdges = mustBeAllDestEdges.get;
                if (!allDestEdges.canFind(edge))
                {
                    graph[destVertex] ~= edge;
                    isEdgeAdd = true;
                }
            }
            else
            {
                throw new Exception("Not found edges for destination vertex " ~ destVertex.toString);
            }

        }

        import std.algorithm.searching : canFind;

        auto mustBeFromEdges = getEdgesForVertex(fromVertex);
        if (!mustBeFromEdges.isNull)
        {
            Edge[] fromEdges = mustBeFromEdges.get;
            if (fromEdges.canFind(edge))
            {
                return isEdgeAdd;
            }
        }

        graph[fromVertex] ~= edge;
        edgeCounter++;

        return true;
    }

    size_t countVertices() nothrow @nogc pure @safe
    {
        return graph.length;
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

        auto fromVertexRemovePos = -1;
        foreach (e; graph[fromVertex])
        {
            fromVertexRemovePos++;
            if (edge == e)
            {
                break;
            }
        }
        if (fromVertexRemovePos != -1)
        {
            graph[fromVertex] = graph[fromVertex].remove(fromVertexRemovePos);
            isRemove = true;
            edgeCounter--;
        }

        Vertex toVertex = edge.dest;
        if (toVertex !is null && hasVertexUnsafe(toVertex))
        {
            //TODO duplicate code
            auto toVertexRemovePos = -1;
            foreach (e; graph[toVertex])
            {
                toVertexRemovePos++;
                if (edge == e)
                {
                    break;
                }
            }

            if (toVertexRemovePos != -1)
            {
                graph[toVertex] = graph[toVertex].remove(toVertexRemovePos);
                //isRemove = true;
            }

        }

        return isRemove;
    }

}

unittest
{
    import deltotum.math.graphs.vertex : Vertex;
    import deltotum.math.graphs.edge : Edge;

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
