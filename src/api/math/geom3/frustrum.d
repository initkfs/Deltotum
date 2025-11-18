module api.math.geom3.frustrum;

import api.math.geom3.plane : Plane;
import api.math.geom2.vec3 : Vec3f;

import Math = api.math;

/**
 * Authors: initkfs
 */

struct Frustrum
{
    Plane[6] planes; // near, far, left, right, top, bottom

    void update(Vec3f cameraPos, Vec3f cameraFront, Vec3f cameraUp, Vec3f cameraRight,
        float fovY, float aspectRatio, float nearDist, float farDist)
    {
        // Near plane, perpendicular to camera front vector
        planes[0] = Plane(cameraFront, (cameraPos + cameraFront).scale(nearDist));

        // Far plane, opposite direction to camera front
        planes[1] = Plane(cameraFront.neg, (cameraPos + cameraFront).scale(farDist));

        float tanHalfFov = Math.tan(fovY / 2.0f);
        float nearHeight = nearDist * tanHalfFov;
        float nearWidth = nearHeight * aspectRatio;

        //corners of near plane in world space
        Vec3f nearCenter = (cameraPos + cameraFront).scale(nearDist);

        // Left plane
        Vec3f leftNormal = cameraUp.cross((cameraFront + cameraRight).scale(nearWidth / nearDist));
        planes[2] = Plane(leftNormal.normalize, cameraPos);

        // Right plane  
        Vec3f rightNormal = (cameraFront - cameraRight).scale(nearWidth / nearDist).cross(cameraUp);
        planes[3] = Plane(rightNormal.normalize, cameraPos);

        // Top plane
        Vec3f topNormal = cameraRight.cross((cameraFront + cameraUp).scale(nearHeight / nearDist));
        planes[4] = Plane(topNormal.normalize, cameraPos);

        // Bottom plane
        Vec3f bottomNormal = ((cameraFront - cameraUp).scale(nearHeight / nearDist))
            .cross(cameraRight);
        planes[5] = Plane(bottomNormal.normalize, cameraPos);
    }

    bool isSphereVisible(Vec3f center, float radius) const
    {
        foreach (plane; planes)
        {
            float distance = plane.signedDistance(center);
            if (distance < -radius)
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

    Plane getPlane(size_t index) const
    {
        assert(index < planes.length, "Plane index out of bounds");
        return planes[index];
    }
}
