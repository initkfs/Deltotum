module api.math.graphs.traversal;

import api.math.graphs.vertex : Vertex;
import api.math.graphs.edge : Edge;
import api.math.graphs.graph : Graph;

/**
 * Authors: initkfs
 */

void dfs(Graph graph, Vertex start, scope bool delegate(Vertex) onVertexIsContinue)
{
    import std.container.slist : SList;

    SList!Vertex stack;

    graph.onVertex((v, edges) { v.isVisited = false; return true; });

    stack.insert(start);

    while (!stack.empty)
    {
        auto v = stack.front;
        stack.removeFront;

        v.isVisited = true;

        if (!onVertexIsContinue(v))
        {
            return;
        }

        graph.onEdgesFromVertex(v, (outEdge) {
            auto dest = outEdge.dest;
            if (dest && !dest.isVisited)
            {
                 stack.insert(dest);
            }
            return true;
        }, isReverse: true);
    }
}

bool dfsSearch(Graph graph, Vertex start, Vertex target)
{
    bool isFound;
    dfs(graph, start, (v) {
        if (v == target)
        {
            isFound = true;
            return false;
        }
        return true;
    });
    return isFound;
}

unittest
{
    auto v1 = new Vertex(1);
    auto v2 = new Vertex(2);
    auto v3 = new Vertex(3);
    auto v4 = new Vertex(4);
    auto v5 = new Vertex(5);
    auto v6 = new Vertex(6);
    auto v7 = new Vertex(7);
    auto v8 = new Vertex(8);

    auto graph = new Graph;
    graph.addEdge([
        new Edge(v1, v2),
        new Edge(v1, v3),
        new Edge(v2, v4),
        new Edge(v2, v5),
        new Edge(v2, v6),
        new Edge(v3, v7),
        new Edge(v3, v8)
    ]);

    Vertex[] dfsExpected = [
        v1, v2, v4, v5, v6, v3, v7, v8
    ];

    Vertex[] dfsResult;
    dfs(graph, v1, (v) { dfsResult ~= v; return true; });

    assert(dfsResult.length == dfsExpected.length);
    assert(dfsResult == dfsExpected);
}

void bfs(Graph graph, Vertex start, scope bool delegate(Vertex) onVertexIsContinue)
{
    import std.container.dlist : DList;

    DList!Vertex queue;

    graph.onVertex((v, edges) { v.isVisited = false; return true; });

    queue.insertBack(start);

    while (!queue.empty)
    {
        auto v = queue.front;
        queue.removeFront;

        v.isVisited = true;

        if (!onVertexIsContinue(v))
        {
            return;
        }

        graph.onEdgesFromVertex(v, (outEdge) {
            auto dest = outEdge.dest;
            if (dest)
            {
                if (!dest.isVisited)
                {
                    queue.insertBack(dest);
                }
            }
            return true;
        });
    }
}

unittest
{
    auto v1 = new Vertex(1);
    auto v2 = new Vertex(2);
    auto v3 = new Vertex(3);
    auto v4 = new Vertex(4);
    auto v5 = new Vertex(5);
    auto v6 = new Vertex(6);
    auto v7 = new Vertex(7);
    auto v8 = new Vertex(8);

    auto graph = new Graph;
    graph.addEdge([
        new Edge(v1, v2),
        new Edge(v1, v3),
        new Edge(v2, v4),
        new Edge(v2, v5),
        new Edge(v2, v6),
        new Edge(v3, v7),
        new Edge(v3, v8)
    ]);

    Vertex[] bfsExpected = [
        v1, v2, v3, v4, v5, v6, v7, v8
    ];

    Vertex[] bfsResult;
    bfs(graph, v1, (v) { bfsResult ~= v; return true; });

    assert(bfsResult.length == bfsExpected.length);
    assert(bfsResult == bfsExpected);
}
