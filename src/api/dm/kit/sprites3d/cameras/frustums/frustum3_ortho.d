module api.dm.kit.sprites3d.cameras.frustums.frustum3_ortho;

import api.dm.kit.sprites3d.cameras.frustums.base_frustum3 : BaseFrustum3f;
import api.math.geom3.plane3 : Plane3f;
import api.math.geom3.vec3 : Vec3f;

import Math = api.math;

/**
 * Authors: initkfs
 */

class Frustum3fOrtho : BaseFrustum3f
{
    this(){}

    this(Vec3f cameraPos, Vec3f cameraFront, Vec3f cameraUp, Vec3f cameraRight,
        float left, float right, float bottom, float top, float nearDist, float farDist)
    {
        recalc(cameraPos, cameraFront, cameraUp, cameraRight,
            left, right, bottom, top, nearDist, farDist);
    }

    void recalc(Vec3f cameraPos, Vec3f cameraFront, Vec3f cameraUp, Vec3f cameraRight,
        float left, float right, float bottom, float top, float nearDist, float farDist)
    {
        // Near/Far
        planes[0] = Plane3f(cameraFront, cameraPos + cameraFront.scale(nearDist));
        planes[1] = Plane3f(-cameraFront, cameraPos + cameraFront.scale(farDist));

        // Left/Right
        planes[2] = Plane3f(cameraRight, cameraPos + cameraRight.scale(left));
        planes[3] = Plane3f(-cameraRight, cameraPos + cameraRight.scale(right));

        // Bottom/Top
        planes[4] = Plane3f(cameraUp, cameraPos + cameraUp.scale(bottom));
        planes[5] = Plane3f(-cameraUp, cameraPos + cameraUp.scale(top));
    }

    override bool isSphereVisible(Vec3f center, float radius, float eps = 1e-5f) const
    {
        foreach (plane; planes)
        {
            if (plane.signedDistance(center) < -radius + eps)
                return false;
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
            {
                return false;
            }
        }
        return true;
    }
}

unittest
{
    import std.stdio;

    void testOrthoFrustumBasic()
    {
        // OpenGL style (looking along -Z)
        Vec3f cameraPos = Vec3f(0, 0, 5);
        Vec3f cameraFront = Vec3f(0, 0, -1);
        Vec3f cameraUp = Vec3f(0, 1, 0);
        Vec3f cameraRight = Vec3f(1, 0, 0);

        float left = -5;
        float right = 5;
        float bottom = -5;
        float top = 5;
        float nearDist = 1;
        float farDist = 10;

        auto frustum = new Frustum3fOrtho(cameraPos, cameraFront, cameraUp, cameraRight,
            left, right, bottom, top, nearDist, farDist);

        Vec3f center = Vec3f(0, 0, 0);
        assert(frustum.isSphereVisible(center, 0.1f), "Center point should be visible");

        // Test points at boundaries
        assert(frustum.isSphereVisible(Vec3f(0, 0, 4), 0.1f), "Point at Z=4 should be visible");
        assert(frustum.isSphereVisible(Vec3f(0, 0, -5), 0.1f), "Point at Z=-5 should be visible");
        assert(!frustum.isSphereVisible(Vec3f(0, 0, 6), 0.1f), "Point behind camera should be invisible");
        assert(!frustum.isSphereVisible(Vec3f(0, 0, -6), 0.1f), "Point beyond far plane should be invisible");

        // Test horizontal boundaries
        assert(frustum.isSphereVisible(Vec3f(4, 0, 0), 0.1f), "Point at X=4 should be visible");
        assert(frustum.isSphereVisible(Vec3f(-4, 0, 0), 0.1f), "Point at X=-4 should be visible");

        Vec3f pointX6 = Vec3f(6, 0, 0);
        assert(!frustum.isSphereVisible(pointX6, 0.1f), "Point at X=6 should be invisible");

        assert(!frustum.isSphereVisible(Vec3f(6, 0, 0), 0.1f), "Point at X=6 should be invisible");
        assert(!frustum.isSphereVisible(Vec3f(-6, 0, 0), 0.1f), "Point at X=-6 should be invisible");

        // Test vertical boundaries
        assert(frustum.isSphereVisible(Vec3f(0, 4, 0), 0.1f), "Point at Y=4 should be visible");
        assert(frustum.isSphereVisible(Vec3f(0, -4, 0), 0.1f), "Point at Y=-4 should be visible");
        assert(!frustum.isSphereVisible(Vec3f(0, 6, 0), 0.1f), "Point at Y=6 should be invisible");
        assert(!frustum.isSphereVisible(Vec3f(0, -6, 0), 0.1f), "Point at Y=-6 should be invisible");
    }

    void testOrthoFrustumSphereRadius()
    {
        Vec3f cameraPos = Vec3f(0, 0, 5);
        Vec3f cameraFront = Vec3f(0, 0, -1);
        Vec3f cameraUp = Vec3f(0, 1, 0);
        Vec3f cameraRight = Vec3f(1, 0, 0);

        float left = -5;
        float right = 5;
        float bottom = -5;
        float top = 5;
        float nearDist = 0.0f;
        float farDist = 10.0f;

        auto frustum = new Frustum3fOrtho(cameraPos, cameraFront, cameraUp, cameraRight,
            left, right, bottom, top, nearDist, farDist);

        // Sphere partially outside but radius makes it visible
        assert(frustum.isSphereVisible(Vec3f(0, 0, 5.2f), 0.3f), "Sphere should be visible due to radius");
        assert(!frustum.isSphereVisible(Vec3f(0, 0, 5.2f), 0.1f), "Sphere should be invisible");

        // Sphere crossing near plane
        assert(frustum.isSphereVisible(Vec3f(0, 0, 5.2f), 0.3f), "Sphere crossing near plane should be visible");
        assert(!frustum.isSphereVisible(Vec3f(0, 0, 5.2f), 0.1f), "Sphere behind near plane should be invisible");

        // Sphere crossing far plane
        assert(frustum.isSphereVisible(Vec3f(0, 0, -4.8f), 0.3f), "Sphere crossing far plane should be visible");
        assert(!frustum.isSphereVisible(Vec3f(0, 0, -5.2f), 0.1f), "Sphere beyond far plane should be invisible");

        // Large sphere that encompasses the frustum
        assert(frustum.isSphereVisible(Vec3f(0, 0, 0), 10.0f), "Large sphere containing frustum should be visible");
    }

    void testOrthoFrustumAABB()
    {
        Vec3f cameraPos = Vec3f(0, 0, 5);
        Vec3f cameraFront = Vec3f(0, 0, -1);
        Vec3f cameraUp = Vec3f(0, 1, 0);
        Vec3f cameraRight = Vec3f(1, 0, 0);

        float left = -5;
        float right = 5;
        float bottom = -5;
        float top = 5;
        float nearDist = 1;
        float farDist = 10;

        auto frustum = new Frustum3fOrtho(cameraPos, cameraFront, cameraUp, cameraRight,
            left, right, bottom, top, nearDist, farDist);

        // AABB completely inside
        assert(frustum.isAABBVisible(Vec3f(-2, -2, -2), Vec3f(2, 2, 2)), "AABB inside should be visible");

        // AABB partially inside
        assert(frustum.isAABBVisible(Vec3f(-6, -2, -2), Vec3f(-4, 2, 2)), "AABB partially inside (left) should be visible");
        assert(frustum.isAABBVisible(Vec3f(4, -2, -2), Vec3f(6, 2, 2)), "AABB partially inside (right) should be visible");
        assert(frustum.isAABBVisible(Vec3f(-2, -6, -2), Vec3f(2, -4, 2)), "AABB partially inside (bottom) should be visible");
        assert(frustum.isAABBVisible(Vec3f(-2, 4, -2), Vec3f(2, 6, 2)), "AABB partially inside (top) should be visible");
        assert(frustum.isAABBVisible(Vec3f(-2, -2, 4), Vec3f(2, 2, 6)), "AABB partially inside (near) should be visible");
        assert(frustum.isAABBVisible(Vec3f(-2, -2, -6), Vec3f(2, 2, -4)), "AABB partially inside (far) should be visible");

        // AABB completely outside
        assert(!frustum.isAABBVisible(Vec3f(-7, -2, -2), Vec3f(-6, 2, 2)), "AABB outside left should be invisible");
        assert(!frustum.isAABBVisible(Vec3f(6, -2, -2), Vec3f(7, 2, 2)), "AABB outside right should be invisible");
        assert(!frustum.isAABBVisible(Vec3f(-2, -7, -2), Vec3f(2, -6, 2)), "AABB outside bottom should be invisible");
        assert(!frustum.isAABBVisible(Vec3f(-2, 6, -2), Vec3f(2, 7, 2)), "AABB outside top should be invisible");
        assert(!frustum.isAABBVisible(Vec3f(-2, -2, 5.5f), Vec3f(2, 2, 6.5f)), "AABB outside near should be invisible");
        assert(!frustum.isAABBVisible(Vec3f(-2, -2, -7), Vec3f(2, 2, -6)), "AABB outside far should be invisible");

        // AABB that contains the frustum
        assert(frustum.isAABBVisible(Vec3f(-10, -10, -10), Vec3f(10, 10, 10)), "AABB containing frustum should be visible");

        // AABB on the boundary
        assert(frustum.isAABBVisible(Vec3f(-5, -5, -5), Vec3f(5, 5, 5)), "AABB exactly on boundaries should be visible");
    }

    void testOrthoFrustumCornerCases()
    {
        // Test with different camera positions and orientations
        {
            Vec3f cameraPos = Vec3f(10, 10, 10);
            Vec3f cameraFront = Vec3f(-1, -1, -1).normalize();
            Vec3f cameraUp = Vec3f(0, 1, 0);
            Vec3f cameraRight = cameraFront.cross(cameraUp).normalize();

            float left = -10;
            float right = 10;
            float bottom = -10;
            float top = 10;
            float nearDist = 1;
            float farDist = 20;

            auto frustum = new Frustum3fOrtho(cameraPos, cameraFront, cameraUp, cameraRight,
                left, right, bottom, top, nearDist, farDist);

            // Point in front of camera (along view direction)
            Vec3f pointInFront = cameraPos + cameraFront.scale(5);
            assert(frustum.isSphereVisible(pointInFront, 0.1f), "Point in front should be visible");

            // Point behind camera
            Vec3f pointBehind = cameraPos - cameraFront.scale(2);
            assert(!frustum.isSphereVisible(pointBehind, 0.1f), "Point behind should be invisible");
        }

        // Test with zero epsilon
        {
            Vec3f cameraPos = Vec3f(0, 0, 5);
            Vec3f cameraFront = Vec3f(0, 0, -1);
            Vec3f cameraUp = Vec3f(0, 1, 0);
            Vec3f cameraRight = Vec3f(1, 0, 0);

            float left = -5;
            float right = 5;
            float bottom = -5;
            float top = 5;
            float nearDist = 1;
            float farDist = 10;

            auto frustum = new Frustum3fOrtho(cameraPos, cameraFront, cameraUp, cameraRight,
                left, right, bottom, top, nearDist, farDist);

            // Test with zero epsilon (exact boundaries)
            assert(frustum.isSphereVisible(Vec3f(5, 0, 0), 0.0f, 0.0f), "Point exactly on right plane should be visible");
            assert(frustum.isSphereVisible(Vec3f(-5, 0, 0), 0.0f, 0.0f), "Point exactly on left plane should be visible");
            assert(frustum.isSphereVisible(Vec3f(0, 5, 0), 0.0f, 0.0f), "Point exactly on top plane should be visible");
            assert(frustum.isSphereVisible(Vec3f(0, -5, 0), 0.0f, 0.0f), "Point exactly on bottom plane should be visible");
            assert(frustum.isSphereVisible(Vec3f(0, 0, 4), 0.0f, 0.0f), "Point exactly on near plane should be visible");
            assert(frustum.isSphereVisible(Vec3f(0, 0, -5), 0.0f, 0.0f), "Point exactly on far plane should be visible");
        }
    }

    void testOrthoFrustumAABBCornerCases()
    {
        // Test AABB with negative extents
        {
            Vec3f cameraPos = Vec3f(0, 0, 5);
            Vec3f cameraFront = Vec3f(0, 0, -1);
            Vec3f cameraUp = Vec3f(0, 1, 0);
            Vec3f cameraRight = Vec3f(1, 0, 0);

            float left = -5;
            float right = 5;
            float bottom = -5;
            float top = 5;
            float nearDist = 1;
            float farDist = 10;

            auto frustum = new Frustum3fOrtho(cameraPos, cameraFront, cameraUp, cameraRight,
                left, right, bottom, top, nearDist, farDist);

            // AABB with min > max (should still work)
            assert(frustum.isAABBVisible(Vec3f(2, 2, 2), Vec3f(-2, -2, -2)), "AABB with inverted extents should still work");
        }

        // Test AABB that touches planes
        {
            Vec3f cameraPos = Vec3f(0, 0, 5);
            Vec3f cameraFront = Vec3f(0, 0, -1);
            Vec3f cameraUp = Vec3f(0, 1, 0);
            Vec3f cameraRight = Vec3f(1, 0, 0);

            float left = -5;
            float right = 5;
            float bottom = -5;
            float top = 5;
            float nearDist = 1;
            float farDist = 10;

            auto frustum = new Frustum3fOrtho(cameraPos, cameraFront, cameraUp, cameraRight,
                left, right, bottom, top, nearDist, farDist);

            // AABB exactly on boundaries
            assert(frustum.isAABBVisible(Vec3f(5, -5, -5), Vec3f(6, 5, 5)), "AABB touching right plane should be visible");
            assert(frustum.isAABBVisible(Vec3f(-6, -5, -5), Vec3f(-5, 5, 5)), "AABB touching left plane should be visible");
            assert(frustum.isAABBVisible(Vec3f(-5, 5, -5), Vec3f(5, 6, 5)), "AABB touching top plane should be visible");
            assert(frustum.isAABBVisible(Vec3f(-5, -6, -5), Vec3f(5, -5, 5)), "AABB touching bottom plane should be visible");
            assert(frustum.isAABBVisible(Vec3f(-5, -5, 4), Vec3f(5, 5, 5)), "AABB touching near plane should be visible");
            assert(frustum.isAABBVisible(Vec3f(-5, -5, -6), Vec3f(5, 5, -5)), "AABB touching far plane should be visible");
        }
    }

    testOrthoFrustumBasic;
    testOrthoFrustumSphereRadius;
    testOrthoFrustumAABB;
    testOrthoFrustumCornerCases;
    testOrthoFrustumAABBCornerCases;
}
