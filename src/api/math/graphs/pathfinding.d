module api.math.graphs.pathfinding;

import api.math.graphs.vertex : Vertex;
import api.math.graphs.edge : Edge;
import api.math.graphs.graph : Graph;

debug import std.stdio : writeln;

/**
 * Authors: initkfs
 */
class IndexableVertex : Vertex
{
    int x;
    int y;

    double priority = 0;

    this(long id, int x, int y) pure @safe
    {
        super(id);
        this.x = x;
        this.y = y;
    }

    alias opEquals = Vertex.opEquals;

    override bool opEquals(Object o) const => this.opEquals(cast(const(IndexableVertex)) o);
    bool opEquals(const IndexableVertex other) const @safe nothrow pure
    {
        if (!other || !super.opEquals(cast(const(Vertex)) other))
        {
            return false;
        }
        return other.x == x && other.y == y && other.priority == priority;
    }

    override size_t toHash() const pure nothrow
    {
        size_t hash = super.toHash;
        hash = x.hashOf(hash);
        hash = y.hashOf(hash);
        return hash;
    }

    override string toString() const
    {
        import std.format : format;

        return format("V(%s,x:%s,y:%s)", id, x, y);
    }
}

class PathGraph : Graph
{
    double heuristic(IndexableVertex a, IndexableVertex b)
    {
        import api.math.geom2.vec2 : Vec2d;

        return Vec2d(b.x, b.y).manhattan(Vec2d(a.x, a.y));
    }
}

bool astar(PathGraph graph, IndexableVertex start, IndexableVertex target, scope bool delegate(
        IndexableVertex) onVertexIsContinue, scope double delegate(IndexableVertex a, IndexableVertex b) costCalc)
{
    import std.container.binaryheap : BinaryHeap;

    assert(graph);
    assert(start);
    assert(target);
    assert(onVertexIsContinue);
    assert(costCalc);

    IndexableVertex[] store;

    IndexableVertex[IndexableVertex] cameFrom;
    double[IndexableVertex] costs;

    auto queue = BinaryHeap!(IndexableVertex[], (a, b) => a.priority > b.priority)(store);

    start.priority = 0;
    queue.insert(start);

    cameFrom[start] = null;
    costs[start] = 0;

    while (queue.length > 0)
    {
        auto current = queue.front;
        queue.removeFront;

        if (!onVertexIsContinue(current))
        {
            return false;
        }

        if (current == target)
        {
            return true;
        }

        graph.onEdgesFromVertex(current, (outEdge) {
            auto next = cast(IndexableVertex) outEdge.dest;
            assert(next);
            double newCost = costs[current] + costCalc(current, next);
            if ((next !in costs) || newCost < costs[next])
            {
                costs[next] = newCost;
                double priority = newCost + graph.heuristic(next, target);
                next.priority = priority;
                queue.insert(next);
                cameFrom[next] = current;
            }
            return true;
        });
    }

    return false;
}

unittest
{
    enum cells = 5;

    auto graph = new PathGraph;

    IndexableVertex[cells][cells] grid;

    IndexableVertex[cells] prevRow;

    size_t id;

    foreach (ri; 0 .. cells)
    {
        IndexableVertex[cells] row;
        foreach (ci; 0 .. cells)
        {
            auto col = new IndexableVertex(id, ci, ri);
            id++;
            row[ci] = col;
            grid[ri][ci] = col;
            if (ci > 0)
            {
                auto prev = row[ci - 1];
                graph.addEdge(new Edge(prev, col));
                graph.addEdge(new Edge(col, prev));
            }
        }

        foreach (pi, ref prevV; prevRow)
        {
            auto current = row[pi];

            if (ri > 0)
            {
                graph.addEdge(new Edge(prevV, current));
                graph.addEdge(new Edge(current, prevV));
            }

            prevV = current;
        }
    }

    auto target = grid[3][2]; //17
    auto start = grid[0][0];

    IndexableVertex[] paths;

    auto isFound = astar(graph, start, target, (v) { paths ~= v; return true; },
        (a, b) {
        if (b.x == 1 && (b.y == 0 || b.y == 1 || b.y == 2))
        {
            return 5;
        }
        return 1;
    });

    assert(isFound);

    IndexableVertex[] expectedPath = [
        new IndexableVertex(0, 0, 0),
        new IndexableVertex(5, 0, 1),
        new IndexableVertex(10, 0, 2),
        new IndexableVertex(15, 0, 3),
        new IndexableVertex(16, 1, 3),
        new IndexableVertex(17, 2, 3)
    ];

    assert(paths.length == expectedPath.length);
    foreach (i, p; paths)
    {
        p.priority = 0;
        p.isVisited = false;

        import std.conv : text;

        auto expected = expectedPath[i];
        assert(p == expected, text(p, ":", expected));
    }

    // foreach (row; grid)
    // {
    //     writeln(row);
    // }
}
