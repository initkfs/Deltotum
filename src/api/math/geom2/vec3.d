module api.math.geom2.vec3;

import Math = api.math;

/**
 * Authors: initkfs
 */
struct Vec3d
{
    double x = 0;
    double y = 0;
    double z = 0;
}

struct Vec3f
{
    float x = 0;
    float y = 0;
    float z = 0;

    Vec3f normalize()
    {
        float length = Math.sqrt(x * x + y * y + z * z);
        if (length > 0)
        {
            return Vec3f(x / length, y / length, z / length);
        }
        return Vec3f(0, 0, 0);
    }

    Vec3f subtract(Vec3f other)
    {
        return Vec3f(x - other.x, y - other.y, z - other.z);
    }

    float dot(Vec3f b)
    {
        return x * b.x + y * b.y + z * b.z;
    }

    Vec3f cross(Vec3f b)
    {
        Vec3f result;
        result.x = y * b.z - z * b.y;
        result.y = z * b.x - x * b.z;
        result.z = x * b.y - y * b.x;
        return result;
    }

}
