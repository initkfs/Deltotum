module dm.addon.math.triangulations.delaunay_triangulator;

import dm.math.vector2 : Vector2;
import dm.math.line2d : Line2d;
import dm.math.triangle2d : Triangle2d;

import Math = dm.math;

import std.typecons;

/** 
 * Some calculations and algorithms ported from the delaunay-triangulator library.
 * https://github.com/jdiemke/delaunay-triangulator under MIT License.
 * TODO Improve ported code
 */

private:

struct LineDistance
{
    Line2d line;
    double distance = 0;

    int cmp(LineDistance other) const @nogc nothrow pure @safe
    {
        import std.math.operations : cmp;

        return cmp(distance, other.distance);
    }
}

bool isPointInCircumCircle(Triangle2d tr, Vector2 point) @nogc pure @safe
{
    immutable double a11 = tr.a.x - point.x;
    immutable double a21 = tr.b.x - point.x;
    immutable double a31 = tr.c.x - point.x;

    immutable double a12 = tr.a.y - point.y;
    immutable double a22 = tr.b.y - point.y;
    immutable double a32 = tr.c.y - point.y;

    immutable double a13 = (tr.a.x - point.x) * (tr.a.x - point.x) + (
        tr.a.y - point.y) * (tr.a.y - point.y);
    immutable double a23 = (tr.b.x - point.x) * (tr.b.x - point.x) + (
        tr.b.y - point.y) * (tr.b.y - point.y);
    immutable double a33 = (tr.c.x - point.x) * (tr.c.x - point.x) + (
        tr.c.y - point.y) * (tr.c.y - point.y);

    immutable double det = a11 * a22 * a33 + a12 * a23 * a31 + a13 * a21 * a32 - a13 * a22 * a31 - a12 * a21 * a33
        - a11 * a23 * a32;

    if (isCounterClockwiseOrient(tr))
    {
        return det > 0.0;
    }

    return det < 0.0;
}

bool isCounterClockwiseOrient(Triangle2d tr) @nogc pure @safe
{
    immutable double a11 = tr.a.x - tr.c.x;
    immutable double a21 = tr.b.x - tr.c.x;

    immutable double a12 = tr.a.y - tr.c.y;
    immutable double a22 = tr.b.y - tr.c.y;

    immutable double det = a11 * a22 - a12 * a21;

    return det > 0;
}

bool isNeighbour(Triangle2d tr, Line2d edge) @nogc pure @safe
{
    return (tr.a == edge.start || tr.b == edge.start || tr.c == edge.start) && (
        tr.a == edge.end || tr.b == edge.end || tr.c == edge
            .end);
}

bool getNoneEdgeVertex(Triangle2d tr, Line2d edge, out Vector2 v) @nogc pure @safe
{
    if (tr.a != edge.start && tr.a != edge.end)
    {
        v = tr.a;
        return true;
    }
    else if (tr.b != edge.start && tr.b != edge.end)
    {
        v = tr.b;
        return true;
    }
    else if (tr.c != edge.start && tr.c != edge.end)
    {
        v = tr.c;
        return true;
    }

    return false;
}

LineDistance findNearestEdge(Triangle2d tr, Vector2 point) @nogc pure @safe
{
    LineDistance[3] edges;

    edges[0] = LineDistance(Line2d(tr.a, tr.b),
        computeClosestPoint(Line2d(tr.a, tr.b), point)
            .subtract(point).magnitude());
    edges[1] = LineDistance(Line2d(tr.b, tr.c),
        computeClosestPoint(Line2d(tr.b, tr.c), point)
            .subtract(point).magnitude());
    edges[2] = LineDistance(Line2d(tr.c, tr.a),
        computeClosestPoint(Line2d(tr.c, tr.a), point)
            .subtract(point).magnitude());

    import std.algorithm.sorting : sort;

    edges[].sort!((e1, e2) => e1.cmp(e2) < 0);

    return edges[0];
}

Vector2 computeClosestPoint(Line2d edge, Vector2 point) @nogc pure @safe
{
    immutable Vector2 ab = edge.end.subtract(edge.start);
    double t = point.subtract(edge.start).dotProduct(ab) / ab.dotProduct(ab);

    if (t < 0.0)
    {
        t = 0.0;
    }
    else if (t > 1.0)
    {
        t = 1.0;
    }

    return edge.start.add(ab.scale(t));
}

class TriangleStore
{

    Triangle2d[] triangles;

    void add(Triangle2d triangle)
    {
        triangles ~= triangle;
    }

    public bool remove(Triangle2d triangle)
    {
        import std.algorithm.searching : countUntil;
        import std.algorithm.mutation : remove;

        auto pos = triangles.countUntil(triangle);
        if (pos == -1)
        {
            return false;
        }
        triangles = triangles.remove(pos);
        return true;
    }

    Nullable!Triangle2d findContainingTriangle(Vector2 point)
    {
        typeof(return) result;
        foreach (Triangle2d triangle; triangles)
        {
            if (triangle.contains(point))
            {
                result = triangle;
                return result;
            }
        }
        return result;
    }

    Nullable!Triangle2d findNeighbour(Triangle2d triangle, Line2d edge)
    {
        typeof(return) result;
        foreach (Triangle2d tr; triangles)
        {
            if (tr.isNeighbour(edge) && tr != triangle)
            {
                result = tr;
                return result;
            }
        }
        return result;
    }

    Nullable!Triangle2d findOneTriangleSharing(Line2d edge)
    {
        typeof(return) result;
        foreach (Triangle2d tr; triangles)
        {
            if (isNeighbour(tr, edge))
            {
                result = tr;
                return result;
            }
        }
        return result;
    }

    Line2d findNearestEdge(Vector2 point)
    {
        LineDistance[] edgeList;

        foreach (Triangle2d triangle; triangles)
        {
            edgeList ~= .findNearestEdge(triangle, point);
        }

        LineDistance[] edges = new LineDistance[](edgeList.length);
        edges[] = edgeList[];

        import std.algorithm.sorting : sort;

        edges.sort!((e1, e2) => e1.distance < e2.distance);
        return edges[0].line;
    }

    void removeTriangles(Vector2 vertex)
    {
        Triangle2d[] forRemove;

        foreach (Triangle2d triangle; triangles)
        {
            if (triangle.hasVertex(vertex))
            {
                forRemove ~= (triangle);
            }
        }

        import std.algorithm.mutation : remove;
        import std.algorithm.searching : canFind;

        triangles = triangles.remove!(x => forRemove.canFind(x));
    }

}

void legalizeEdge(TriangleStore triangles, Triangle2d triangle, Line2d edge, Vector2 newVertex)
{
    auto mustBeNeighbourTriangle = triangles.findNeighbour(triangle, edge);

    if (!mustBeNeighbourTriangle.isNull)
    {
        auto neighbourTriangle = mustBeNeighbourTriangle.get;
        if (neighbourTriangle.isPointInCircumCircle(newVertex))
        {
            triangles.remove(triangle);
            triangles.remove(neighbourTriangle);

            Vector2 noneEdgeVertex;
            neighbourTriangle.getNoneEdgeVertex(edge, noneEdgeVertex);

            Triangle2d firstTriangle = Triangle2d(noneEdgeVertex, edge.start, newVertex);
            Triangle2d secondTriangle = Triangle2d(noneEdgeVertex, edge.end, newVertex);

            triangles.add(firstTriangle);
            triangles.add(secondTriangle);

            legalizeEdge(triangles, firstTriangle, Line2d(noneEdgeVertex, edge.start), newVertex);
            legalizeEdge(triangles, secondTriangle, Line2d(noneEdgeVertex, edge.end), newVertex);
        }
    }
}

public Triangle2d[] triangulate(Vector2[] pointSet)
{
    TriangleStore triangles = new TriangleStore();

    if (pointSet == null || pointSet.length < 3)
    {
        throw new Exception("Less than three points in point set.");
    }

    double maxOfAnyCoordinate = 0.0;

    foreach (Vector2 vector; pointSet)
    {
        maxOfAnyCoordinate = Math.max(Math.max(vector.x, vector.y), maxOfAnyCoordinate);
    }

    maxOfAnyCoordinate *= 16.0;

    Vector2 p1 = Vector2(0.0, 3.0 * maxOfAnyCoordinate);
    Vector2 p2 = Vector2(3.0 * maxOfAnyCoordinate, 0.0);
    Vector2 p3 = Vector2(-3.0 * maxOfAnyCoordinate, -3.0 * maxOfAnyCoordinate);

    Triangle2d superTriangle = Triangle2d(p1, p2, p3);

    triangles.add(superTriangle);

    for (int i = 0; i < pointSet.length; i++)
    {
        auto mustBeTriangle = triangles.findContainingTriangle(pointSet[i]);

        if (mustBeTriangle.isNull)
        {
            Line2d edge = triangles.findNearestEdge(pointSet[i]);

            auto mustBeFirst = triangles.findOneTriangleSharing(edge);
            if (mustBeFirst.isNull)
            {
                continue;
            }
            auto first = mustBeFirst.get;

            auto mustBeSecond = triangles.findNeighbour(first, edge);

            if (mustBeSecond.isNull)
            {
                continue;
            }

            auto second = mustBeSecond.get;

            Vector2 firstNoneEdgeVertex;
            Vector2 secondNoneEdgeVertex;

            first.getNoneEdgeVertex(edge, firstNoneEdgeVertex);
            second.getNoneEdgeVertex(edge, secondNoneEdgeVertex);

            triangles.remove(first);
            triangles.remove(second);

            Triangle2d triangle1 = Triangle2d(edge.start, firstNoneEdgeVertex, pointSet[i]);
            Triangle2d triangle2 = Triangle2d(edge.end, firstNoneEdgeVertex, pointSet[i]);
            Triangle2d triangle3 = Triangle2d(edge.start, secondNoneEdgeVertex, pointSet[i]);
            Triangle2d triangle4 = Triangle2d(edge.end, secondNoneEdgeVertex, pointSet[i]);

            triangles.add(triangle1);
            triangles.add(triangle2);
            triangles.add(triangle3);
            triangles.add(triangle4);

            legalizeEdge(triangles, triangle1, Line2d(edge.start, firstNoneEdgeVertex), pointSet[i]);
            legalizeEdge(triangles, triangle2, Line2d(edge.end, firstNoneEdgeVertex), pointSet[i]);
            legalizeEdge(triangles, triangle3, Line2d(edge.start, secondNoneEdgeVertex), pointSet[i]);
            legalizeEdge(triangles, triangle4, Line2d(edge.end, secondNoneEdgeVertex), pointSet[i]);
        }
        else
        {
            /*
            * The vertex is inside a triangle.
            */
            Triangle2d triangle = mustBeTriangle.get;
            Vector2 a = triangle.a;
            Vector2 b = triangle.b;
            Vector2 c = triangle.c;

            triangles.remove(triangle);

            Triangle2d first = Triangle2d(a, b, pointSet[i]);
            Triangle2d second = Triangle2d(b, c, pointSet[i]);
            Triangle2d third = Triangle2d(c, a, pointSet[i]);

            triangles.add(first);
            triangles.add(second);
            triangles.add(third);

            legalizeEdge(triangles, first, Line2d(a, b), pointSet[i]);
            legalizeEdge(triangles, second, Line2d(b, c), pointSet[i]);
            legalizeEdge(triangles, third, Line2d(c, a), pointSet[i]);
        }
    }

    triangles.removeTriangles(superTriangle.a);
    triangles.removeTriangles(superTriangle.b);
    triangles.removeTriangles(superTriangle.c);

    return triangles.triangles;
}
