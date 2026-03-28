module api.dm.kit.sprites3d.cameras.frustums.frustum3_persp;

import api.dm.kit.sprites3d.cameras.frustums.base_frustum3 : BaseFrustum3f;
import api.math.geom3.plane3 : Plane3f;
import api.math.geom3.vec3 : Vec3f;

import Math = api.math;

/**
 * Authors: initkfs
 */

class Frustum3fPersp : BaseFrustum3f
{
    this()
    {

    }

    this(Vec3f cameraPos, Vec3f cameraFront, Vec3f cameraUp, Vec3f cameraRight,
        float fovYRad, float aspectRatio, float nearDist, float farDist)
    {
        recalc(cameraPos, cameraFront, cameraUp, cameraRight,
            fovYRad, aspectRatio, nearDist, farDist);
    }

    void recalc(Vec3f cameraPos, Vec3f cameraFront, Vec3f cameraUp, Vec3f cameraRight,
        float fovYRad, float aspectRatio, float nearDist, float farDist)
    {
        planes[0] = Plane3f(cameraFront, cameraPos + cameraFront.scale(nearDist));
        planes[1] = Plane3f(-cameraFront, cameraPos + cameraFront.scale(farDist));

        float h = Math.tan(fovYRad / 2.0f);
        float w = h * aspectRatio;

        Vec3f leftDir = cameraFront - cameraRight.scale(w);
        planes[2] = Plane3f(leftDir.cross(cameraUp).normalize(), cameraPos);

        Vec3f rightDir = cameraFront + cameraRight.scale(w);
        planes[3] = Plane3f(cameraUp.cross(rightDir).normalize(), cameraPos);

        Vec3f bottomDir = cameraFront - cameraUp.scale(h);
        planes[4] = Plane3f(cameraRight.cross(bottomDir).normalize(), cameraPos);

        Vec3f topDir = cameraFront + cameraUp.scale(h);
        planes[5] = Plane3f(topDir.cross(cameraRight).normalize(), cameraPos);
    }

    static Frustum3fPersp createForLeftHanded(Vec3f cameraPos, Vec3f cameraUp, Vec3f cameraRight,
        float fovYRad, float aspectRatio, float nearDist, float farDist)
    {
        auto frustum = new Frustum3fPersp();
        Vec3f cameraFront = Vec3f(0, 0, 1);
        frustum.recalc(cameraPos, cameraFront, -cameraUp, cameraRight,
            fovYRad, aspectRatio, nearDist, farDist);

        return frustum;
    }

    override bool isSphereVisible(Vec3f center, float radius, float eps = 1e-5f) const
    {
        foreach (plane; planes)
        {
            float distance = plane.signedDistance(center);
            if (distance < -radius + eps)
            {
                return false;
            }
        }
        return true;
    }

    override bool isAABBVisible(Vec3f minCorner, Vec3f maxCorner) const
    {
        foreach (plane; planes)
        {
            Vec3f positiveVertex = Vec3f(
                (plane.normal.x > 0) ? maxCorner.x
                    : minCorner.x,
                    (plane.normal.y > 0) ? maxCorner.y
                    : minCorner.y,
                    (plane.normal.z > 0) ? maxCorner.z : minCorner.z
            );

            if (plane.signedDistance(positiveVertex) < 0)
                return false;
        }
        return true;
    }

}

unittest
{
    testCameraLookingForward;
    testCameraLookingForwardLH;
    testSphereVisibility;
    testAABBVisibility;
    testBoundaryCases;
}

version (unittest)
{
    import std.conv : to;
    import std.stdio : writeln;

    void testCameraLookingForward()
    {
        Vec3f cameraPos = Vec3f(0, 0, 5);
        Vec3f cameraFront = Vec3f(0, 0, -1).normalize;
        Vec3f cameraUp = Vec3f(0, 1, 0);
        Vec3f cameraRight = Vec3f(1, 0, 0);

        float fovY = Math.degToRad(60.0f);
        float aspect = 16.0f / 9.0f;
        float nearDist = 1.0f;
        float farDist = 10.0f;

        auto frustum = new Frustum3fPersp(cameraPos, cameraFront, cameraUp, cameraRight,
            fovY, aspect, nearDist, farDist);

        foreach (i, plane; frustum.planes)
        {
            float length = plane.normal.length;
            assert(Math.abs(length - 1.0f) < 0.001f,
                "Plane3f " ~ to!string(i) ~ " normal not normalize: " ~ to!string(length));
            // writeln("Plane3f ", i, " normal: (", plane.normal.x, ", ", plane.normal.y, ", ", plane.normal.z, ") d: ", plane
            //         .distance);
        }

        Vec3f pointInFront = Vec3f(0, 0, 0);
        assert(frustum.isSphereVisible(pointInFront, 0.1f), "Point in front should be visible");

        Vec3f pointBehind = Vec3f(0, 0, 6);
        assert(!frustum.isSphereVisible(pointBehind, 0.1f), "Point behind should be invisible");
    }

    void testCameraLookingForwardLH()
    {
        Vec3f cameraPos = Vec3f(0, 0, 5);
        Vec3f cameraUp = Vec3f(0, 1, 0);
        Vec3f cameraRight = Vec3f(1, 0, 0);

        float fovY = Math.degToRad(60.0f);
        float aspect = 16.0f / 9.0f;
        float nearDist = 1.0f;
        float farDist = 10.0f;

        auto frustum = Frustum3fPersp.createForLeftHanded(cameraPos, cameraUp, cameraRight,
            fovY, aspect, nearDist, farDist);

        Vec3f pointInFront = Vec3f(0, 0, 10);
        assert(frustum.isSphereVisible(pointInFront, 0.1f), "Point in front should be visible");

        Vec3f pointBehind = Vec3f(0, 0, 5.5f);
        assert(!frustum.isSphereVisible(pointBehind, 0.1f), "Point behind should be invisible");
    }

    void testSphereVisibility()
    {
        Vec3f cameraPos = Vec3f(0, 0, 0);
        Vec3f cameraFront = Vec3f(0, 0, -1).normalize;
        Vec3f cameraUp = Vec3f(0, 1, 0);
        Vec3f cameraRight = Vec3f(1, 0, 0);

        auto frustum = new Frustum3fPersp(cameraPos, cameraFront, cameraUp, cameraRight,
            Math.degToRad(90.0f), 1.0f, 1.0f, 10.0f);

        assert(frustum.isSphereVisible(Vec3f(0, 0, -5), 1.0f), "Center sphere should be visible");
        assert(!frustum.isSphereVisible(Vec3f(10, 0, -5), 1.0f), "Right sphere should be invisible");
        assert(frustum.isSphereVisible(Vec3f(0.8f, 0, -5), 0.5f), "Partial sphere should be visible");
    }

    void testAABBVisibility()
    {
        Vec3f cameraPos = Vec3f(0, 0, 0);
        Vec3f cameraFront = Vec3f(0, 0, -1).normalize;
        Vec3f cameraUp = Vec3f(0, 1, 0);
        Vec3f cameraRight = Vec3f(1, 0, 0);

        auto frustum = new Frustum3fPersp(cameraPos, cameraFront, cameraUp, cameraRight,
            Math.degToRad(90.0f), 1.0f, 1.0f, 10.0f);

        assert(frustum.isAABBVisible(Vec3f(-1, -1, -6), Vec3f(1, 1, -4)), "Center AABB should be visible");
        assert(!frustum.isAABBVisible(Vec3f(10, 10, -5), Vec3f(11, 11, -4)), "Outside AABB should be invisible");
    }

    void testBoundaryCases()
    {
        Vec3f cameraPos = Vec3f(0, 0, 5);
        Vec3f cameraFront = Vec3f(0, 0, -1).normalize;

        auto frustum = new Frustum3fPersp(cameraPos, cameraFront, Vec3f(0, 1, 0), Vec3f(1, 0, 0),
            Math.degToRad(60.0f), 16.0f / 9.0f, 1.0f, 10.0f);

        assert(!frustum.isSphereVisible(Vec3f(0, 0, -5.1f), 0.1f), "Point beyond far plane should be invisible");
        assert(!frustum.isSphereVisible(Vec3f(15, 0, -5), 1.0f), "Point far to the right should be invisible"); // 
        assert(!frustum.isSphereVisible(Vec3f(-15, 0, -5), 1.0f), "Point far to the left should be invisible"); // 
        assert(!frustum.isSphereVisible(Vec3f(0, 10, -5), 1.0f), "Point far above should be invisible");
        assert(!frustum.isSphereVisible(Vec3f(0, -10, -5), 1.0f), "Point far below should be invisible");
    }
}
