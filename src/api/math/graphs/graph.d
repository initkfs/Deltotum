module api.math.graphs.graph;

import api.math.graphs.vertex : Vertex;
import api.math.graphs.edge : Edge;

import std.typecons : Nullable;
import std.container.dlist : DList;

/**
 * Authors: initkfs
 */
class Graph
{
    private
    {
        DList!Edge*[Vertex] graph;
        size_t edgeCounter;
    }

    bool addVertex(Vertex vertex) @safe
    {
        if (!vertex)
        {
            throw new Exception("Vertex must not be null");
        }

        if (hasVertexUnsafe(vertex))
        {
            return false;
        }

        return addVertexUnsafe(vertex);
    }

    bool addVertexUnsafe(Vertex vertex) @safe
    {
        graph[vertex] = new DList!Edge;
        return true;
    }

    protected DList!Edge** hasVertexUnsafe(Vertex vertex) nothrow @safe
    {
        return (vertex in graph);
    }

    bool hasVertex(Vertex vertex) @safe
    {
        if (!vertex)
        {
            throw new Exception("Vertex must not be null");
        }

        return hasVertexUnsafe(vertex) !is null;
    }

    void onEdgeForVertex(Vertex vertex, scope bool delegate(Edge) onEdgeIsContinue, bool isReverse = false)
    {
        auto edgesPtr = hasVertexUnsafe(vertex);
        if (!edgesPtr)
        {
            return;
        }

        if (!isReverse)
        {
            foreach (edge; (**edgesPtr)[])
            {
                if (!onEdgeIsContinue(edge))
                {
                    return;
                }
            }
        }
        else
        {
            foreach_reverse (edge; (**edgesPtr)[])
            {
                if (!onEdgeIsContinue(edge))
                {
                    return;
                }
            }
        }

    }

    DList!Edge* edgesForVertexUnsafe(Vertex vertex)
    {
        if (auto edgesPtr = hasVertexUnsafe(vertex))
        {
            return *edgesPtr;
        }
        return null;
    }

    Nullable!(DList!Edge*) edgesForVertex(Vertex vertex)
    {
        if (auto edgesPtr = hasVertexUnsafe(vertex))
        {
            return Nullable!(DList!Edge*)(*edgesPtr);
        }
        return Nullable!(DList!Edge*).init;
    }

    void onEdgesToVertex(Vertex vertex, scope bool delegate(Edge) onEdgeIsContinue, bool isReverse = false)
    {
        onEdgeForVertex(vertex, (Edge edge) {
            if (edge.dest == vertex)
            {
                return onEdgeIsContinue(edge);
            }
            return true;
        }, isReverse);
    }

    Edge[] edgesToVertex(Vertex vertex, bool isReverse = false)
    {
        Edge[] edges;
        onEdgesToVertex(vertex, (Edge edge) { edges ~= edge; return true; }, isReverse);
        return edges;
    }

    void onEdgesFromVertex(Vertex vertex, scope bool delegate(Edge) onEdgeIsContinue, bool isReverse = false)
    {
        onEdgeForVertex(vertex, (Edge edge) {
            if (edge.src == vertex)
            {
                return onEdgeIsContinue(edge);
            }
            return true;
        }, isReverse);
    }

    Edge[] edgesFromVertex(Vertex vertex, bool isReverse = false)
    {
        Edge[] edges;
        onEdgesFromVertex(vertex, (Edge edge) { edges ~= edge; return true; }, isReverse);
        return edges;
    }

    bool addEdge(Vertex a, Vertex b) => addEdge(new Edge(a, b));

    bool addEdgeBoth(Vertex a, Vertex b)
    {
        bool isAdd;
        isAdd |= addEdge(a, b);
        isAdd |= addEdge(b, a);
        return isAdd;
    }

    bool addEdge(Edge[] edges)
    {
        bool isAdd;
        foreach (e; edges)
        {
            isAdd |= addEdge(e);
        }
        return isAdd;
    }

    bool addEdge(Edge edge)
    {
        if (!edge)
        {
            throw new Exception("Edge must not be null");
        }

        if (!edge.src)
        {
            throw new Exception("Edge source vertex must not be null");
        }

        if (!edge.dest)
        {
            throw new Exception("Edge destination vertex must not be null");
        }

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

        DList!Edge* destEdges = edgesForVertexUnsafe(destVertex);
        if (destEdges && !((*destEdges)[].canFind(edge)))
        {
            destEdges.insert(edge);
            isEdgeAdd = true;
        }

        DList!Edge* fromEdges = edgesForVertexUnsafe(fromVertex);
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

    size_t countVertices() nothrow pure @safe => graph.length;
    size_t countEdges() nothrow pure @safe => edgeCounter;

    bool removeEdge(Edge edge)
    {
        import std.algorithm.searching : countUntil;
        import std.algorithm.mutation : remove;
        import std.algorithm.searching : canFind;

        bool isRemove;

        Vertex fromVertex = edge.src;
        DList!(Edge)** mustBeFromEdgesPtr = hasVertexUnsafe(fromVertex);
        if (mustBeFromEdgesPtr)
        {
            DList!(Edge)* fromEdgesPtr = *mustBeFromEdgesPtr;
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
        DList!(Edge)** mustBeDestEdgesPtr = hasVertexUnsafe(toVertex);
        if (mustBeDestEdgesPtr)
        {
            DList!(Edge)* destEdgesPtr = *mustBeDestEdgesPtr;
            if ((*destEdgesPtr)[].canFind(edge))
            {
                (*destEdgesPtr).linearRemoveElement(edge);
            }
        }

        return isRemove;
    }

    void onVertex(scope bool delegate(Vertex, DList!Edge*) onVertexIsContinue)
    {
        foreach (v, edges; graph)
        {
            if (!onVertexIsContinue(v, edges))
            {
                return;
            }
        }
    }
}

unittest
{
    import api.math.graphs.vertex : Vertex;
    import api.math.graphs.edge : Edge;

    Vertex v1 = new Vertex(1);
    Vertex v11 = new Vertex(1);

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

    Vertex v2 = new Vertex(2);
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
