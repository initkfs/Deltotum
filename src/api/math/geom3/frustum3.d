module api.math.geom3.frustum3;

import api.math.geom3.plane3 : Plane3f;
import api.math.geom3.vec3 : Vec3f;

import Math = api.math;

/**
 * Authors: initkfs
 */

struct Frustum3f
{
    Plane3f[6] planes; // near, far, left, right, top, bottom

    this(Vec3f cameraPos, Vec3f cameraFront, Vec3f cameraUp, Vec3f cameraRight,
        float fovYRad, float aspectRatio, float nearDist, float farDist)
    {
        // Near и Far planes for RH
        planes[0] = Plane3f(cameraFront, cameraPos + cameraFront.scale(nearDist));
        planes[1] = Plane3f(-cameraFront, cameraPos + cameraFront.scale(farDist));

        float tanHalfFov = Math.tan(fovYRad / 2.0f);
        float nearHeight = nearDist * tanHalfFov;
        float nearWidth = nearHeight * aspectRatio;

        Vec3f nearCenter = cameraPos + cameraFront.scale(nearDist);

        Vec3f nearTopLeft = nearCenter + cameraUp.scale(nearHeight) - cameraRight.scale(nearWidth);
        Vec3f nearTopRight = nearCenter + cameraUp.scale(nearHeight) + cameraRight.scale(nearWidth);
        Vec3f nearBottomLeft = nearCenter - cameraUp.scale(
            nearHeight) - cameraRight.scale(nearWidth);

        // Left plane
        Vec3f leftNormal = cameraUp.cross(nearTopLeft - cameraPos).normalize;
        planes[2] = Plane3f(-leftNormal, cameraPos);

        // Right plane  
        Vec3f rightNormal = (nearTopRight - cameraPos).cross(cameraUp).normalize;
        planes[3] = Plane3f(-rightNormal, cameraPos);

        // Top plane
        Vec3f topNormal = cameraRight.cross(nearTopLeft - cameraPos).normalize;
        planes[4] = Plane3f(-topNormal, cameraPos);

        // Bottom plane
        Vec3f bottomNormal = (nearBottomLeft - cameraPos).cross(cameraRight).normalize;
        planes[5] = Plane3f(-bottomNormal, cameraPos);
    }

    static Frustum3f createForLeftHanded(Vec3f cameraPos, Vec3f cameraUp, Vec3f cameraRight,
        float fovYRad, float aspectRatio, float nearDist, float farDist)
    {
        Frustum3f frustum;
        Vec3f cameraFront = Vec3f(0, 0, 1).normalize;

        frustum.planes[0] = Plane3f(Vec3f(0, 0, 1), cameraPos + cameraFront.scale(nearDist));
        frustum.planes[1] = Plane3f(Vec3f(0, 0, -1), cameraPos + cameraFront.scale(farDist));

        float tanHalfFov = Math.tan(fovYRad / 2.0f);
        float nearHeight = nearDist * tanHalfFov;
        float nearWidth = nearHeight * aspectRatio;

        Vec3f nearCenter = cameraPos + cameraFront.scale(nearDist);

        Vec3f nearTopLeft = nearCenter + cameraUp.scale(nearHeight) - cameraRight.scale(nearWidth);
        Vec3f nearTopRight = nearCenter + cameraUp.scale(nearHeight) + cameraRight.scale(nearWidth);
        Vec3f nearBottomLeft = nearCenter - cameraUp.scale(
            nearHeight) - cameraRight.scale(nearWidth);

        // Left plane to right
        frustum.planes[2] = Plane3f(Vec3f(1, 0, 0), nearTopLeft);

        // Right plane to left
        frustum.planes[3] = Plane3f(Vec3f(-1, 0, 0), nearTopRight);

        // Top plane - to down
        frustum.planes[4] = Plane3f(Vec3f(0, -1, 0), nearTopLeft);

        // Bottom plane - to up, inverted
        frustum.planes[5] = Plane3f(Vec3f(0, 1, 0), nearBottomLeft);

        return frustum;
    }

    bool isSphereVisible(Vec3f center, float radius, float eps = 1e-5f) const
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

    bool isAABBVisible(Vec3f minCorner, Vec3f maxCorner) const
    {
        foreach (plane; planes)
        {
            Vec3f negativeVertex = Vec3f(
                (plane.normal.x > 0) ? minCorner.x
                    : maxCorner.x,
                (plane.normal.y > 0) ? minCorner.y
                    : maxCorner.y,
                (plane.normal.z > 0) ? minCorner.z : maxCorner.z
            );

            if (plane.signedDistance(negativeVertex) < 0)
            {
                return false;
            }
        }
        return true;
    }

    Plane3f getPlane(size_t index) const
    {
        assert(index < planes.length, "Plane3f index out of bounds");
        return planes[index];
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

        auto frustum = Frustum3f(cameraPos, cameraFront, cameraUp, cameraRight,
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

        auto frustum = Frustum3f.createForLeftHanded(cameraPos, cameraUp, cameraRight,
            fovY, aspect, nearDist, farDist);

        // writeln("Near plane normal: (", frustum.planes[0].normal.x, ", ",
        //     frustum.planes[0].normal.y, ", ", frustum.planes[0].normal.z, ")");
        // writeln("Far plane normal: (", frustum.planes[1].normal.x, ", ",
        //     frustum.planes[1].normal.y, ", ", frustum.planes[1].normal.z, ")");

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

        auto frustum = Frustum3f(cameraPos, cameraFront, cameraUp, cameraRight,
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

        auto frustum = Frustum3f(cameraPos, cameraFront, cameraUp, cameraRight,
            Math.degToRad(90.0f), 1.0f, 1.0f, 10.0f);

        assert(frustum.isAABBVisible(Vec3f(-1, -1, -6), Vec3f(1, 1, -4)), "Center AABB should be visible");
        assert(!frustum.isAABBVisible(Vec3f(10, 10, -5), Vec3f(11, 11, -4)), "Outside AABB should be invisible");
    }

    void testBoundaryCases()
    {
        Vec3f cameraPos = Vec3f(0, 0, 5);
        Vec3f cameraFront = Vec3f(0, 0, -1).normalize;

        auto frustum = Frustum3f(cameraPos, cameraFront, Vec3f(0, 1, 0), Vec3f(1, 0, 0),
            Math.degToRad(60.0f), 16.0f / 9.0f, 1.0f, 10.0f);

        assert(!frustum.isSphereVisible(Vec3f(0, 0, -5.1f), 0.1f), "Point beyond far plane should be invisible");
        assert(!frustum.isSphereVisible(Vec3f(15, 0, -5), 1.0f), "Point far to the right should be invisible"); // 
        assert(!frustum.isSphereVisible(Vec3f(-15, 0, -5), 1.0f), "Point far to the left should be invisible"); // 
        assert(!frustum.isSphereVisible(Vec3f(0, 10, -5), 1.0f), "Point far above should be invisible");
        assert(!frustum.isSphereVisible(Vec3f(0, -10, -5), 1.0f), "Point far below should be invisible");
    }
}
