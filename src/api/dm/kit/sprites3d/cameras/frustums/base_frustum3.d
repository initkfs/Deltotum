module api.dm.kit.sprites3d.cameras.frustums.base_frustum3;

import api.math.geom3.plane3 : Plane3f;
import api.math.geom3.vec3 : Vec3f;

import Math = api.math;

/**
 * Authors: initkfs
 */

class BaseFrustum3f
{
    Plane3f[6] planes; // near, far, left, right, top, bottom

    Plane3f getPlane(size_t index) const
    {
        assert(index < planes.length, "Plane3f index out of bounds");
        return planes[index];
    }

    abstract {
        bool isSphereVisible(Vec3f center, float radius, float eps = 1e-5f) const;
        bool isAABBVisible(Vec3f minCorner, Vec3f maxCorner) const;
    }
}