module api.math.triangulations.delaunator;
/**
 * Authors: initkfs
 */
import Math = api.math;
import api.math.geom2.vec2 : Vec2d;

/** 
  * Ported from https://github.com/nol1fe/delaunator-sharp. Copyright (c) 2019 Patryk Grech
  * Under MIT License: https://github.com/nol1fe/delaunator-sharp/blob/master/LICENSE
  */

struct Edge
{
    Vec2d P;
    Vec2d Q;
    int index;

    this(int e, Vec2d p, Vec2d q)
    {
        index = e;
        P = p;
        Q = q;
    }
}

struct Triangle
{
    int index;

    Vec2d[] points;

    this(int t, Vec2d[] newPoints)
    {
        points = newPoints;
        index = t;
    }
}

struct VoronoiCell
{
    Vec2d[] points;
    int index;
    this(int triangleIndex, Vec2d[] newPoints)
    {
        points = newPoints;
        index = triangleIndex;
    }
}

class Delaunator
{
    private
    {
        double epsilon = double.epsilon;
        int[] edgeStack = new int[](512);

        Vec2d[] points;

        // One value per half-edge, containing the point index of where a given half edge starts.
        int[] triangles;
        // One value per half-edge, containing the opposite half-edge in the adjacent triangle, or -1 if there is no adjacent triangle
        int[] halfedges;
        // A list of point indices that traverses the hull of the points.
        int[] hull;

        int hashSize;
        int[] hullPrev;
        int[] hullNext;
        int[] hullTri;
        int[] hullHash;

        double cx = 0;
        double cy = 0;

        int trianglesLen;
        double[] coords;
        int hullStart;
        int hullSize;
    }

    void triangulate(Vec2d[] newPoints)
    {
        if (newPoints.length < 3)
        {
            throw new Exception("Need at least 3 newPoints");
        }

        points = newPoints;

        coords = new double[](points.length * 2);

        for (size_t i = 0; i < points.length; i++)
        {
            auto p = points[i];
            coords[2 * i] = p.x;
            coords[2 * i + 1] = p.y;
        }

        auto n = newPoints.length;
        auto maxTriangles = 2 * n - 5;

        triangles = new int[](maxTriangles * 3);

        halfedges = new int[](maxTriangles * 3);
        hashSize = cast(int) Math.ceil(Math.sqrt(n));

        hullPrev = new int[](n);
        hullNext = new int[](n);
        hullTri = new int[](n);
        hullHash = new int[](hashSize);

        auto ids = new int[](n);

        auto minX = double.infinity;
        auto minY = double.infinity;
        auto maxX = -double.infinity;
        auto maxY = -double.infinity;

        for (auto i = 0; i < n; i++)
        {
            auto x = coords[2 * i];
            auto y = coords[2 * i + 1];
            if (x < minX)
                minX = x;
            if (y < minY)
                minY = y;
            if (x > maxX)
                maxX = x;
            if (y > maxY)
                maxY = y;
            ids[i] = i;
        }

        auto cx = (minX + maxX) / 2;
        auto cy = (minY + maxY) / 2;

        auto minDist = double.infinity;
        auto i0 = 0;
        auto i1 = 0;
        auto i2 = 0;

        // pick a seed point close to the center
        for (int i = 0; i < n; i++)
        {
            auto d = dist(cx, cy, coords[2 * i], coords[2 * i + 1]);
            if (d < minDist)
            {
                i0 = i;
                minDist = d;
            }
        }
        auto i0x = coords[2 * i0];
        auto i0y = coords[2 * i0 + 1];

        minDist = double.infinity;

        // find the point closest to the seed
        for (int i = 0; i < n; i++)
        {
            if (i == i0)
                continue;
            auto d = dist(i0x, i0y, coords[2 * i], coords[2 * i + 1]);
            if (d < minDist && d > 0)
            {
                i1 = i;
                minDist = d;
            }
        }

        auto i1x = coords[2 * i1];
        auto i1y = coords[2 * i1 + 1];

        auto minRadius = double.infinity;

        // find the third point which forms the smallest circumcircle with the first two
        for (int i = 0; i < n; i++)
        {
            if (i == i0 || i == i1)
                continue;
            auto r = circumradius(i0x, i0y, i1x, i1y, coords[2 * i], coords[2 * i + 1]);
            if (r < minRadius)
            {
                i2 = i;
                minRadius = r;
            }
        }
        auto i2x = coords[2 * i2];
        auto i2y = coords[2 * i2 + 1];

        if (minRadius == double.infinity)
        {
            throw new Exception("No Delaunay triangulation exists for this input.");
        }

        if (orient(i0x, i0y, i1x, i1y, i2x, i2y))
        {
            auto i = i1;
            auto x = i1x;
            auto y = i1y;
            i1 = i2;
            i1x = i2x;
            i1y = i2y;
            i2 = i;
            i2x = x;
            i2y = y;
        }

        auto center = circumcenter(i0x, i0y, i1x, i1y, i2x, i2y);
        this.cx = center.x;
        this.cy = center.y;

        auto dists = new double[](n);
        for (auto i = 0; i < n; i++)
        {
            dists[i] = dist(coords[2 * i], coords[2 * i + 1], center.x, center.y);
        }

        // sort the points by distance from the seed triangle circumcenter
        quicksort(ids, dists, 0, cast(int)(n - 1));

        // set up the seed triangle as the starting hull
        hullStart = i0;
        hullSize = 3;

        hullNext[i0] = hullPrev[i2] = i1;
        hullNext[i1] = hullPrev[i0] = i2;
        hullNext[i2] = hullPrev[i1] = i0;

        hullTri[i0] = 0;
        hullTri[i1] = 1;
        hullTri[i2] = 2;

        hullHash[hashKey(i0x, i0y)] = i0;
        hullHash[hashKey(i1x, i1y)] = i1;
        hullHash[hashKey(i2x, i2y)] = i2;

        trianglesLen = 0;
        addTriangle(i0, i1, i2, -1, -1, -1);

        double xp = 0;
        double yp = 0;

        for (auto k = 0; k < ids.length; k++)
        {
            auto i = ids[k];
            auto x = coords[2 * i];
            auto y = coords[2 * i + 1];

            // skip near-duplicate points
            if (k > 0 && Math.abs(x - xp) <= epsilon && Math.abs(y - yp) <= epsilon)
                continue;
            xp = x;
            yp = y;

            // skip seed triangle points
            if (i == i0 || i == i1 || i == i2)
                continue;

            // find a visible edge on the convex hull using edge hash
            auto start = 0;
            for (auto j = 0; j < hashSize; j++)
            {
                auto key = hashKey(x, y);
                start = hullHash[(key + j) % hashSize];
                if (start != -1 && start != hullNext[start])
                    break;
            }

            start = hullPrev[start];
            auto e = start;
            auto q = hullNext[e];

            while (!orient(x, y, coords[2 * e], coords[2 * e + 1], coords[2 * q], coords[2 * q + 1]))
            {
                e = q;
                if (e == start)
                {
                    e = int.max;
                    break;
                }

                q = hullNext[e];
            }

            if (e == int.max)
                continue; // likely a near-duplicate point; skip it

            // add the first triangle from the point
            auto t = addTriangle(e, i, hullNext[e], -1, -1, hullTri[e]);

            // recursively flip triangles from the point until they satisfy the Delaunay condition
            hullTri[i] = legalize(t + 2);
            hullTri[e] = t; // keep track of boundary triangles on the hull
            hullSize++;

            // walk forward through the hull, adding more triangles and flipping recursively
            auto next = hullNext[e];
            q = hullNext[next];

            while (orient(x, y, coords[2 * next], coords[2 * next + 1], coords[2 * q], coords[2 * q + 1]))
            {
                t = addTriangle(next, i, q, hullTri[i], -1, hullTri[next]);
                hullTri[i] = legalize(t + 2);
                hullNext[next] = next; // mark as removed
                hullSize--;
                next = q;

                q = hullNext[next];
            }

            // walk backward from the other side, adding more triangles and flipping
            if (e == start)
            {
                q = hullPrev[e];

                while (orient(x, y, coords[2 * q], coords[2 * q + 1], coords[2 * e], coords[2 * e + 1]))
                {
                    t = addTriangle(q, i, e, -1, hullTri[e], hullTri[q]);
                    legalize(t + 2);
                    hullTri[q] = t;
                    hullNext[e] = e; // mark as removed
                    hullSize--;
                    e = q;

                    q = hullPrev[e];
                }
            }

            // update the hull indices
            hullStart = hullPrev[i] = e;
            hullNext[e] = hullPrev[next] = i;
            hullNext[i] = next;

            // save the two new edges in the hash table
            hullHash[hashKey(x, y)] = i;
            hullHash[hashKey(coords[2 * e], coords[2 * e + 1])] = e;
        }

        hull = new int[](hullSize);
        auto s = hullStart;
        for (size_t i = 0; i < hullSize; i++)
        {
            hull[i] = s;
            s = hullNext[s];
        }

        hullPrev = hullNext = hullTri = null; // get rid of temporary arrays

        /// trim typed triangle mesh arrays
        triangles = triangles[0 .. trianglesLen];
        halfedges = halfedges[0 .. trianglesLen];
    }

    private int legalize(int a)
    {
        auto i = 0;
        int ar;

        // recursion eliminated with a fixed-size stack
        while (true)
        {
            auto b = halfedges[a];

            /* if the pair of triangles doesn't satisfy the Delaunay condition
                 * (p1 is inside the circumcircle of [p0, pl, pr]), flip them,
                 * then do the same check/flip recursively for the new pair of triangles
                 *
                 *           pl                    pl
                 *          /||\                  /  \
                 *       al/ || \bl            al/    \a
                 *        /  ||  \              /      \
                 *       /  a||b  \    flip    /___ar___\
                 *     p0\   ||   /p1   =>   p0\---bl---/p1
                 *        \  ||  /              \      /
                 *       ar\ || /br             b\    /br
                 *          \||/                  \  /
                 *           pr                    pr
                 */
            int a0 = a - a % 3;
            ar = a0 + (a + 2) % 3;

            if (b == -1)
            { // convex hull edge
                if (i == 0)
                    break;
                a = edgeStack[--i];
                continue;
            }

            auto b0 = b - b % 3;
            auto al = a0 + (a + 1) % 3;
            auto bl = b0 + (b + 2) % 3;

            auto p0 = triangles[ar];
            auto pr = triangles[a];
            auto pl = triangles[al];
            auto p1 = triangles[bl];

            auto illegal = inCircle(
                coords[2 * p0], coords[2 * p0 + 1],
                coords[2 * pr], coords[2 * pr + 1],
                coords[2 * pl], coords[2 * pl + 1],
                coords[2 * p1], coords[2 * p1 + 1]);

            if (illegal)
            {
                triangles[a] = p1;
                triangles[b] = p0;

                auto hbl = halfedges[bl];

                // edge swapped on the other side of the hull (rare); fix the halfedge reference
                if (hbl == -1)
                {
                    auto e = hullStart;
                    do
                    {
                        if (hullTri[e] == bl)
                        {
                            hullTri[e] = a;
                            break;
                        }
                        e = hullPrev[e];
                    }
                    while (e != hullStart);
                }
                link(a, hbl);
                link(b, halfedges[ar]);
                link(ar, bl);

                auto br = b0 + (b + 1) % 3;

                // don't worry about hitting the cap: it can only happen on extremely degenerate input
                if (i < edgeStack.length)
                {
                    edgeStack[i++] = br;
                }
            }
            else
            {
                if (i == 0)
                    break;
                a = edgeStack[--i];
            }
        }

        return ar;
    }

    private bool inCircle(double ax, double ay, double bx, double by, double cx, double cy, double px, double py)
    {
        auto dx = ax - px;
        auto dy = ay - py;
        auto ex = bx - px;
        auto ey = by - py;
        auto fx = cx - px;
        auto fy = cy - py;

        auto ap = dx * dx + dy * dy;
        auto bp = ex * ex + ey * ey;
        auto cp = fx * fx + fy * fy;

        return dx * (ey * cp - bp * fy) -
            dy * (ex * cp - bp * fx) +
            ap * (ex * fy - ey * fx) < 0;
    }

    private int addTriangle(int i0, int i1, int i2, int a, int b, int c)
    {
        auto t = trianglesLen;

        triangles[t] = i0;
        triangles[t + 1] = i1;
        triangles[t + 2] = i2;

        link(t, a);
        link(t + 1, b);
        link(t + 2, c);

        trianglesLen += 3;
        return t;
    }

    private void link(int a, int b)
    {
        halfedges[a] = b;
        if (b != -1)
            halfedges[b] = a;
    }

    private int hashKey(double x, double y) => cast(int)(Math.floor(pseudoAngle(x - cx, y - cy) * hashSize) % hashSize);

    private double pseudoAngle(double dx, double dy)
    {
        auto p = dx / (Math.abs(dx) + Math.abs(dy));
        return (dy > 0 ? 3 - p : 1 + p) / 4; // [0..1]
    }

    private void quicksort(int[] ids, double[] dists, int left, int right)
    {
        if (right - left <= 20)
        {
            for (auto i = left + 1; i <= right; i++)
            {
                auto temp = ids[i];
                auto tempDist = dists[temp];
                auto j = i - 1;
                while (j >= left && dists[ids[j]] > tempDist)
                    ids[j + 1] = ids[j--];
                ids[j + 1] = temp;
            }
        }
        else
        {
            auto median = (left + right) >> 1;
            auto i = left + 1;
            auto j = right;

            swap(ids, median, i);
            if (dists[ids[left]] > dists[ids[right]])
                swap(ids, left, right);
            if (dists[ids[i]] > dists[ids[right]])
                swap(ids, i, right);
            if (dists[ids[left]] > dists[ids[i]])
                swap(ids, left, i);

            auto temp = ids[i];
            auto tempDist = dists[temp];
            while (true)
            {
                do
                    i++;
                while (dists[ids[i]] < tempDist);
                do
                    j--;
                while (dists[ids[j]] > tempDist);
                if (j < i)
                    break;
                swap(ids, i, j);
            }
            ids[left + 1] = ids[j];
            ids[j] = temp;

            if (right - i + 1 >= j - left)
            {
                quicksort(ids, dists, i, right);
                quicksort(ids, dists, left, j - 1);
            }
            else
            {
                quicksort(ids, dists, left, j - 1);
                quicksort(ids, dists, i, right);
            }
        }
    }

    private void swap(int[] arr, int i, int j)
    {
        auto tmp = arr[i];
        arr[i] = arr[j];
        arr[j] = tmp;
    }

    private bool orient(double px, double py, double qx, double qy, double rx, double ry) => (
        qy - py) * (rx - qx) - (qx - px) * (ry - qy) < 0;
    private double circumradius(double ax, double ay, double bx, double by, double cx, double cy)
    {
        auto dx = bx - ax;
        auto dy = by - ay;
        auto ex = cx - ax;
        auto ey = cy - ay;
        auto bl = dx * dx + dy * dy;
        auto cl = ex * ex + ey * ey;
        auto d = 0.5 / (dx * ey - dy * ex);
        auto x = (ey * bl - dy * cl) * d;
        auto y = (dx * cl - ex * bl) * d;
        return x * x + y * y;
    }

    private Vec2d circumcenter(double ax, double ay, double bx, double by, double cx, double cy)
    {
        auto dx = bx - ax;
        auto dy = by - ay;
        auto ex = cx - ax;
        auto ey = cy - ay;
        auto bl = dx * dx + dy * dy;
        auto cl = ex * ex + ey * ey;
        auto d = 0.5 / (dx * ey - dy * ex);
        auto x = ax + (ey * bl - dy * cl) * d;
        auto y = ay + (dx * cl - ex * bl) * d;

        return Vec2d(x, y);
    }

    private double dist(double ax, double ay, double bx, double by)
    {
        auto dx = ax - bx;
        auto dy = ay - by;
        return dx * dx + dy * dy;
    }

    Triangle[] getTriangles()
    {
        Triangle[] trigs;
        for (auto t = 0; t < triangles.length / 3; t++)
        {
            trigs ~= Triangle(t, trianglePoints(t));
        }
        return trigs;
    }

    Edge[] getEdges()
    {
        Edge[] edges;
        for (auto e = 0; e < triangles.length; e++)
        {
            if (e > halfedges[e])
            {
                auto p = points[triangles[e]];
                auto q = points[triangles[nextHalfedge(e)]];
                edges ~= Edge(e, p, q);
            }
        }
        return edges;
    }

    Edge[] voronoiEdges(Vec2d delegate(int) triangleVerticeSelector = null)
    {
        Edge[] edges;
        if (triangleVerticeSelector == null)
            triangleVerticeSelector = x => centroid(x);
        for (auto e = 0; e < triangles.length; e++)
        {
            if (e < halfedges[e])
            {
                auto p = triangleVerticeSelector(triangleOfEdge(e));
                auto q = triangleVerticeSelector(triangleOfEdge(halfedges[e]));
                edges ~= Edge(e, p, q);
            }
        }
        return edges;
    }

    Edge[] voronoiEdgesOnCircumCenter() => voronoiEdges(&triangleCircumcenter);
    Edge[] voronoiEdgesOnCentroids() => voronoiEdges(&centroid);

    VoronoiCell[] voronoiCells(Vec2d delegate(int) triangleVerticeSelector = null)
    {
        VoronoiCell[] cells;
        if (triangleVerticeSelector == null)
            triangleVerticeSelector = x => centroid(x);

        struct HashSet
        {
            int[] set;

            bool add(int data)
            {
                foreach (v; set)
                {
                    if (data == v)
                    {
                        return false;
                    }
                }
                set ~= data;
                return true;
            }

        }

        HashSet seen;
        Vec2d[] vertices; // Keep it outside the loop, reuse capacity, less resizes.

        for (auto e = 0; e < triangles.length; e++)
        {
            auto pointIndex = triangles[nextHalfedge(e)];
            // True if element was added, If resize the set? O(n) : O(1)
            if (seen.add(pointIndex))
            {
                foreach (edge; edgesAroundPoint(e))
                {

                    // triangleVerticeSelector cant be null, no need to check before invoke (?.).
                    vertices ~= triangleVerticeSelector(triangleOfEdge(edge));
                }
                cells ~= VoronoiCell(pointIndex, vertices);
                vertices = []; // Clear elements, keep capacity
            }
        }

        return cells;
    }

    VoronoiCell[] voronoiCellsOnCircumcenters() => voronoiCells(
        &triangleCircumcenter);
    VoronoiCell[] voronoiCellsOnCentroids() => voronoiCells(&centroid);

    Edge[] hullEdges() => createHull(hullPoints());

    Vec2d[] hullPoints()
    {
        Vec2d[] newPoints;
        foreach (x; hull)
        {
            newPoints ~= points[x];
        }
        return newPoints;
    }

    Vec2d[] trianglePoints(int t)
    {
        Vec2d[] newPoints;
        foreach (p; pointsOfTriangle(t))
        {
            newPoints ~= points[p];
        }
        return newPoints;
    }

    Vec2d[] rellaxedPoints()
    {
        Vec2d[] newPoints;
        foreach (cell; voronoiCellsOnCircumcenters())
        {
            newPoints ~= centroid(cell.points);
        }
        return newPoints;
    }

    Edge[] getEdgesOfTriangle(int t)
    {
        import std : map, array;

        Edge[] edges = createHull(edgesOfTriangle(t).map!(p => points[p]).array);
        return edges;
    }

    Edge[] createHull(Vec2d[] newPoints)
    {
        import std.range : zip;
        import std.array : array;

        Edge[] edges;

        //newPoints.Skip(1).Append(newPoints.FirstOrDefault())
        foreach (tup; zip(newPoints, newPoints[1 .. $] ~ newPoints[0]))
        {
            edges ~= Edge(0, tup[0], tup[1]);
        }
        return edges;
    }

    Vec2d triangleCircumcenter(int t)
    {
        auto vertices = trianglePoints(t);
        return calcCircumcenter(vertices[0], vertices[1], vertices[2]);
    }

    Vec2d centroid(int t)
    {
        auto vertices = trianglePoints(t);
        return centroid(vertices);
    }

    Vec2d calcCircumcenter(Vec2d a, Vec2d b, Vec2d c) => circumcenter(a.x, a.y, b.x, b.y, c.x, c
            .y);

    Vec2d centroid(Vec2d[] newPoints)
    {
        double accumulatedArea = 0.0f;
        double centerX = 0.0f;
        double centerY = 0.0f;

        for (int i = 0, j = cast(int)(newPoints.length - 1); i < newPoints.length;
            j = i++)
        {
            auto temp = newPoints[i].x * newPoints[j].y - newPoints[j].x * newPoints[i].y;
            accumulatedArea += temp;
            centerX += (newPoints[i].x + newPoints[j].x) * temp;
            centerY += (newPoints[i].y + newPoints[j].y) * temp;
        }

        if (Math.abs(accumulatedArea) < 1E-7f)
            return Vec2d();

        accumulatedArea *= 3f;
        return Vec2d(centerX / accumulatedArea, centerY / accumulatedArea);
    }

    void eachTriangle(void delegate(Triangle) callback)
    {
        foreach (triangle; getTriangles())
        {
            callback(triangle);
        }
    }

    void eachTriangleEdge(void delegate(Edge) callback)
    {
        foreach (edge; getEdges())
        {
            callback(edge);
        }
    }

    void eachVoronoiEdge(void delegate(Edge) callback)
    {
        foreach (edge; voronoiEdges())
        {
            callback(edge);
        }
    }

    void eachVoronoiCellOnCentroids(void delegate(VoronoiCell) callback)
    {
        foreach (cell; voronoiCellsOnCentroids())
        {
            callback(cell);
        }
    }

    void eachVoronoiCellOnCircumcenters(void delegate(VoronoiCell) callback)
    {
        foreach (cell; voronoiCellsOnCircumcenters())
        {
            callback(cell);
        }
    }

    void eachVoronoiCell(void delegate(VoronoiCell) callback, Vec2d delegate(int) triangleVertexSelector = null)
    {
        foreach (cell; voronoiCells(triangleVertexSelector))
        {
            callback(cell);
        }
    }

    // Returns the half-edges that share a start point with the given half edge, in order.
    int[] edgesAroundPoint(int start)
    {
        int[] result;
        auto incoming = start;
        do
        {
            result ~= incoming;
            auto outgoing = nextHalfedge(incoming);
            incoming = halfedges[outgoing];
        }
        while (incoming != -1 && incoming != start);
        return result;
    }

    //Returns the three point indices of a given triangle id.
    int[] pointsOfTriangle(int t)
    {
        int[] res;
        foreach (edge; edgesOfTriangle(t))
        {
            res ~= triangles[edge];
        }
        return res;
    }

    // Returns the triangle ids adjacent to the given triangle id.
    // Will return up to three values.
    int[] trianglesAdjacentToTriangle(int t)
    {
        int[] adjacentTriangles;
        auto triangleEdges = edgesOfTriangle(t);
        foreach (e; triangleEdges)
        {
            auto opposite = halfedges[e];
            if (opposite >= 0)
            {
                adjacentTriangles ~= triangleOfEdge(opposite);
            }
        }
        return adjacentTriangles;
    }

    int nextHalfedge(int e) => (e % 3 == 2) ? e - 2 : e + 1;
    int previousHalfedge(int e) => (e % 3 == 0) ? e + 2 : e - 1;

    // Returns the three half-edges of a given triangle id.
    int[] edgesOfTriangle(int t) => [3 * t, 3 * t + 1, 3 * t + 2];

    // Returns the triangle id of a given half-edge.
    int triangleOfEdge(int e)
    {
        return e / 3;
    }
}

unittest
{
    import std.math.operations : isClose;

    double eps = 0.0001;

    Vec2d[] newPoints = [
        Vec2d(10, 10),
        Vec2d(20, 15),
        Vec2d(15, 15),
        Vec2d(12, 12),
        Vec2d(5, 5),
    ];

    auto generator = new Delaunator;

    generator.triangulate(newPoints);

    Triangle[] expectedTriangles = [
        Triangle(0, [
            Vec2d(x : 12.0000000000, y:
                12.0000000000), Vec2d(x : 20.0000000000, y:
                15.0000000000), Vec2d(x : 10.0000000000, y:
                10.0000000000)
        ]),
        Triangle(1, [
            Vec2d(x : 12.0000000000, y:
                12.0000000000), Vec2d(x : 15.0000000000, y:
                15.0000000000), Vec2d(x : 20.0000000000, y:
                15.0000000000)
        ]),
        Triangle(2, [
            Vec2d(x : 20.0000000000, y:
                15.0000000000), Vec2d(x : 5.0000000000, y:
                5.0000000000), Vec2d(x : 10.0000000000, y:
                10.0000000000)
        ])
    ];

    Triangle[] receivedTrigs = generator.getTriangles;
    assert(receivedTrigs == expectedTriangles);
    foreach (i, trig; receivedTrigs)
    {
        auto expectedTrig = expectedTriangles[i];
        assert(trig.index == expectedTrig.index);
        assert(trig.points == expectedTrig.points);
        foreach (pi, trigPoint; trig.points)
        {
            auto expPoint = expectedTrig.points[pi];
            assert(isClose(trigPoint.x, expPoint.x, eps));
            assert(isClose(trigPoint.y, expPoint.y, eps));
        }
    }

     Vec2d[][] expectedCells = [
        [Vec2d(14, 12.3333)],
        [Vec2d(14, 12.3333), Vec2d(11.6667, 10)],
        [Vec2d(15.6667, 14)],
        [Vec2d(14, 12.3333), Vec2d(15.6667, 14)],
        [Vec2d(11.6667, 10)]
    ];

    auto vcells1 = generator.voronoiCells;
    assert(vcells1.length == expectedCells.length);

    import std.conv : text;

    foreach (vcell; vcells1)
    {
        auto exCell = expectedCells[cast(size_t) vcell.index];
        assert(exCell.length == vcell.points.length);
        foreach (vi, vv; vcell.points)
        {
            assert(isClose(exCell[vi].x, vv.x, eps), text(exCell[vi].x, ":", vv.x));
            assert(isClose(exCell[vi].y, vv.y, eps), text(exCell[vi].y, ":", vv.y));
        }
    }
}
