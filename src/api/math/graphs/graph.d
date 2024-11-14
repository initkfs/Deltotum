module api.math.graphs.graph;

import api.math.graphs.vertex : Vertex;
import api.math.graphs.edge : Edge;

import std.typecons : Nullable;
import std.container.slist : SList;

/**
 * Authors: initkfs
 */
class Graph
{
    private
    {
        SList!Edge*[Vertex] graph;
        size_t edgeCounter;
    }

    bool addVertex(Vertex vertex) @safe
    {
        import std.exception : enforce;

        enforce(vertex, "Vertex must not be null");

        if (hasVertexUnsafe(vertex))
        {
            return false;
        }

        return addVertexUnsafe(vertex);
    }

    bool addVertexUnsafe(Vertex vertex) @safe
    {
        graph[vertex] = new SList!Edge;
        return true;
    }

    protected SList!Edge** hasVertexUnsafe(Vertex vertex) nothrow @nogc @safe
    {
        return (vertex in graph);
    }

    bool hasVertex(Vertex vertex) @safe
    {
        import std.exception : enforce;

        enforce(vertex, "Vertex must not be null");
        return hasVertexUnsafe(vertex) !is null;
    }

    void onEdgeForVertex(Vertex vertex, scope bool delegate(Edge) onEdgeIsContinue)
    {
        auto edgesPtr = hasVertexUnsafe(vertex);
        if (!edgesPtr)
        {
            return;
        }

        foreach (edge; (**edgesPtr)[])
        {
            if (!onEdgeIsContinue(edge))
            {
                return;
            }
        }
    }

    SList!Edge* edgesForVertexUnsafe(Vertex vertex)
    {
        if (auto edgesPtr = hasVertexUnsafe(vertex))
        {
            return *edgesPtr;
        }
        return null;
    }

    Nullable!(SList!Edge*) edgesForVertex(Vertex vertex)
    {
        if (auto edgesPtr = hasVertexUnsafe(vertex))
        {
            return Nullable!(SList!Edge*)(*edgesPtr);
        }
        return Nullable!(SList!Edge*).init;
    }

    void onEdgesToVertex(Vertex vertex, scope bool delegate(Edge) onEdgeIsContinue)
    {
        onEdgeForVertex(vertex, (Edge edge) {
            if (edge.dest == vertex)
            {
                return onEdgeIsContinue(edge);
            }
            return true;
        });
    }

    Edge[] edgesToVertex(Vertex vertex)
    {
        Edge[] edges;;
        onEdgesToVertex(vertex, (Edge edge) { edges ~= edge; return true; });
        return edges;
    }

    void onEdgesFromVertex(Vertex vertex, scope bool delegate(Edge) onEdgeIsContinue)
    {
        onEdgeForVertex(vertex, (Edge edge) {
            if (edge.src == vertex)
            {
                return onEdgeIsContinue(edge);
            }
            return true;
        });
    }

    Edge[] edgesFromVertex(Vertex vertex)
    {
        Edge[] edges;
        onEdgesFromVertex(vertex, (Edge edge) { edges ~= edge; return true; });
        return edges;
    }

    bool addEdge(Edge edge)
    {
        import std.exception : enforce;

        enforce(edge, "Edge must not be null");
        enforce(edge.src, "Edge source vertex must not be null");
        enforce(edge.dest, "Edge destination vertex must not be null");

        Vertex fromVertex = edge.src;
        if (!hasVertexUnsafe(fromVertex))
        {
            if (!addVertexUnsafe(fromVertex))
            {
                import std.format : format;

                throw new Exception(format("Error adding source vertex %s for edge %s", fromVertex, edge));
            }
        }

        Vertex destVertex = edge.dest;
        if (!hasVertexUnsafe(destVertex))
        {
            if (!addVertexUnsafe(destVertex))
            {
                import std.format : format;

                throw new Exception(format("Error adding destination vertex %s for edge %s", destVertex, edge));
            }
        }

        bool isEdgeAdd;

        import std.algorithm.searching : canFind;

        SList!Edge* destEdges = edgesForVertexUnsafe(destVertex);
        if (destEdges && !((*destEdges)[].canFind(edge)))
        {
            destEdges.insert(edge);
            isEdgeAdd = true;
        }

        SList!Edge* fromEdges = edgesForVertexUnsafe(fromVertex);
        if (fromEdges)
        {
            if ((*fromEdges)[].canFind(edge))
            {
                return isEdgeAdd;
            }

            fromEdges.insert(edge);
            edgeCounter++;

            return true;
        }
        return false;
    }

    size_t countVertices() nothrow @nogc pure @safe => graph.length;
    size_t countEdges() nothrow @nogc pure @safe => edgeCounter;

    bool removeEdge(Edge edge)
    {
        import std.algorithm.searching : countUntil;
        import std.algorithm.mutation : remove;
        import std.algorithm.searching : canFind;

        bool isRemove;

        Vertex fromVertex = edge.src;
        SList!(Edge)** mustBeFromEdgesPtr = hasVertexUnsafe(fromVertex);
        if (mustBeFromEdgesPtr)
        {
            SList!(Edge)* fromEdgesPtr = *mustBeFromEdgesPtr;
            if ((*fromEdgesPtr)[].canFind(edge))
            {
                if ((*fromEdgesPtr).linearRemoveElement(edge))
                {
                    isRemove = true;
                    edgeCounter--;
                }
            }
        }

        Vertex toVertex = edge.dest;
        SList!(Edge)** mustBeDestEdgesPtr = hasVertexUnsafe(toVertex);
        if (mustBeDestEdgesPtr)
        {
            SList!(Edge)* destEdgesPtr = *mustBeDestEdgesPtr;
            if ((*destEdgesPtr)[].canFind(edge))
            {
               (*destEdgesPtr).linearRemoveElement(edge);
            }
        }

        return isRemove;
    }

}

unittest
{
    import api.math.graphs.vertex : Vertex;
    import api.math.graphs.edge : Edge;

    Vertex v1 = new Vertex("1");
    Vertex v11 = new Vertex("1");

    Graph graph = new Graph;

    assert(graph.addVertex(v1));
    assert(graph.hasVertex(v1));
    assert(graph.hasVertex(v11));
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

    assert(graph.edgesFromVertex(v1) == [e1]);
    assert(graph.edgesToVertex(v1) == [e2]);
    assert(graph.edgesFromVertex(v2) == [e2]);
    assert(graph.edgesToVertex(v2) == [e1]);

    assert(graph.removeEdge(e1));
    assert(graph.countEdges == 1);
    assert(graph.edgesFromVertex(v1).length == 0);
    assert(graph.edgesToVertex(v2).length == 0);
    assert(graph.edgesToVertex(v1) == [e2]);
    assert(graph.edgesFromVertex(v2) == [e2]);
}
