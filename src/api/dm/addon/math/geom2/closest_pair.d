module api.dm.addon.math.geom2.closest_pair;

import Math = api.math;
import api.math.geom2.vec2 : Vec2d;

/**
 * Authors: initkfs
 */

/** 
 * https://en.wikipedia.org/wiki/Closest_pair_of_points_problem
 * http://www.cs.umd.edu/class/fall2013/cmsc451/Lects/lect10.pdf 
 * https://www.geeksforgeeks.org/closest-pair-of-points-using-divide-and-conquer-algorithm/
 */
struct ClosestPair
{
    Vec2d p1;
    Vec2d p2;
    float distance = 0;

    enum maxDistance = float.max;

    static ClosestPair infinity() => ClosestPair(Vec2d.infinity, Vec2d.infinity, maxDistance);
    bool isInfinity() => p1.isInfinity || p2.isInfinity;
}

protected void sortByX(Vec2d[] points)
{
    import std.algorithm.sorting : sort;

    points.sort!((p1, p2) => p1.x < p2.x);
}

protected void sortByY(Vec2d[] points)
{
    import std.algorithm.sorting : sort;

    points.sort!((p1, p2) => p1.y < p2.y);
}

ClosestPair closestBruteForce(Vec2d[] points) => closestBruteForce(points, points.length);

ClosestPair closestBruteForce(Vec2d[] points, size_t len)
{
    ClosestPair closestPair = ClosestPair.infinity;

    if (len > points.length)
    {
        len = points.length;
    }

    enum minPoints = 3;
    if (points.length < minPoints || len < minPoints)
    {
        return closestPair;
    }

    foreach (i; 0 .. len)
    {
        foreach (j; (i + 1) .. len)
        {
            immutable p1 = points[i];
            immutable p2 = points[j];
            immutable distance = p1.distanceTo(p2);
            if (distance < closestPair.distance)
            {
                closestPair = ClosestPair(p1, p2, distance);
            }
        }
    }
    return closestPair;
}

unittest
{
    import std.math.operations : isClose;

    Vec2d[] vecs = [
        {14, 10}, {10, 10}, {5, 10}, {10, 3}, {11, 11}, {10, 21}
    ];

    auto pair1 = closestBruteForce(vecs);
    assert(isClose(pair1.p1.x, 10));
    assert(isClose(pair1.p1.y, 10));
    assert(isClose(pair1.p2.x, 11));
    assert(isClose(pair1.p2.y, 11));
    assert(isClose(pair1.distance, 1.41421, 0.00001));

    auto pair2 = closestBruteForce(vecs, 100);
    assert(isClose(pair2.distance, 1.41421, 0.00001));

    auto pair3 = closestBruteForce(vecs, 2);
    assert(pair3.p1.isInfinity);
    assert(pair3.p2.isInfinity);
    assert(pair3.distance == float.max);
}

protected ClosestPair stripClosestPoint(Vec2d[] points, size_t len, float minDistance)
{
    if (len > points.length)
    {
        len = points.length;
    }

    ClosestPair minPair = ClosestPair.infinity;

    if (points.length == 0 || len == 0)
    {
        return minPair;
    }

    minPair.distance = minDistance;

    points[0 .. len].sortByX;

    foreach (i; 0 .. len)
    {
        for (auto j = i + 1; j < len && (points[j].y - points[i].y) < minPair.distance;
            ++j)
        {
            auto p1 = points[i];
            auto p2 = points[j];
            auto distp1p2 = p1.distanceTo(p2);
            if (distp1p2 < minPair.distance)
            {
                minPair = ClosestPair(p1, p2, distp1p2);
            }
        }
    }

    if(minPair.isInfinity){
        minPair.distance = ClosestPair.maxDistance;
    }

    return minPair;
}

protected ClosestPair closestDaQ(Vec2d[] sortedXPoints, size_t startIndex, size_t endIndex)
{
    assert(startIndex <= endIndex);
    enum minPoints = 3;
    immutable size_t indexRange = endIndex - startIndex;
    if (indexRange <= minPoints)
    {
        return closestBruteForce(sortedXPoints, endIndex);
    }

    immutable size_t middleIndex = startIndex + indexRange / 2;
    immutable Vec2d midPoint = sortedXPoints[middleIndex];

    immutable ClosestPair distLeft = closestDaQ(sortedXPoints, startIndex, middleIndex);
    immutable ClosestPair distRight = closestDaQ(sortedXPoints, middleIndex, endIndex);

    immutable ClosestPair minDist = distLeft.distance < distRight.distance ? distLeft : distRight;

    //TODO free memory
    Vec2d[] closerMinDist = new Vec2d[](endIndex);
    int j;
    foreach (i; 0 .. endIndex)
    {
        if (Math.abs(sortedXPoints[i].x - midPoint.x) < minDist.distance)
        {
            closerMinDist[j] = sortedXPoints[i];
            j++;
        }
    }

    immutable closerDist = stripClosestPoint(closerMinDist, j, minDist.distance);
    immutable ClosestPair result = minDist.distance < closerDist.distance ? minDist : closerDist;
    return result;
}

ClosestPair closestDaQ(Vec2d[] points) => closestDaQ(points, points.length);

ClosestPair closestDaQ(Vec2d[] points, size_t len)
{
    ClosestPair minPair = ClosestPair.infinity;
    if(len > points.length){
        len = points.length;
    }

    if(points.length == 0 || len == 0){
        return minPair;
    }

    auto pCopy = points.dup;
    pCopy[0 .. len].sortByY;
    return closestDaQ(pCopy, 0, len);
}

unittest
{
    import std.math.operations : isClose;

    Vec2d[] vecs = [
        {14, 10}, {10, 10}, {5, 10}, {10, 3}, {11, 11}, {10, 21}
    ];

    auto closest1 = closestDaQ(vecs);
    assert(isClose(closest1.p1.x, 10));
    assert(isClose(closest1.p1.y, 10));
    assert(isClose(closest1.p2.x, 11));
    assert(isClose(closest1.p2.y, 11));
    assert(isClose(closest1.distance, 1.41421, 0.00001));
}
