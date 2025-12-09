module api.math.geom3.plane3;

import api.math.geom3.vec3: Vec3f;

/**
 * Authors: initkfs
 * 3D plane in normal form: ax + by + cz + d = 0
 */
struct Plane3f
{
    Vec3f normal;
    float distance = 0;

    this(Vec3f normal, Vec3f point)
    {
        this.normal = normal.normalize;
        this.distance = -this.normal.dot(point);
    }

    this(Vec3f normal, float distance)
    {
        this.normal = normal.normalize;
        this.distance = distance;
    }

    this(Vec3f a, Vec3f b, Vec3f c)
    {
        Vec3f ab = b - a;
        Vec3f ac = c - a;
        this.normal = ab.cross(ac).normalize;
        this.distance = -this.normal.dot(a);
    }

    // positive = in front of plane, negative = behind plane, zero = on plane
    float signedDistance(Vec3f point) const => normal.dot(point) + distance;

    bool isInFront(Vec3f point, float tolerance = 0.0f) const => signedDistance(point) > -tolerance;
    bool isInPlane(Vec3f point, float tolerance = 0.0f) const {
        import std.math.operations: isClose;

        return isClose(signedDistance(point), 0, tolerance);
    }

}
