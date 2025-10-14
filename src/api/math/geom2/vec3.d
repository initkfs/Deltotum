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

    struct SphericalCoords
    {
        float radius = 0;
        float theta = 0; // XY 0..2π
        float phi = 0; // Z  0..π
    }

    static nothrow pure @safe Vec3f zero() => Vec3f();
    nothrow pure @safe bool isZero() const => (x == 0) && (y == 0) && (z == 0);
    static nothrow pure @safe Vec3f infinity() => Vec3f(float.infinity, float.infinity, float
            .infinity);
    bool isInfinity() const => (x == float.infinity) || (y == float.infinity || (z == float
            .infinity));

    Vec3f add(Vec3f other) const nothrow pure @safe
    {
        return Vec3f(x + other.x, y + other.y, z + other.z);
    }

    Vec3f subtract(Vec3f other) const nothrow pure @safe
    {
        return Vec3f(x - other.x, y - other.y, z - other.z);
    }

    Vec3f subtractAbs(Vec3f other) const nothrow pure @safe
    {
        import Math = api.dm.math;

        return Vec3f(Math.abs(x - other.x), Math.abs(y - other.y), Math.abs(z - other.z));
    }

    Vec3f normalize() const nothrow pure @safe
    {
        const double length = magnitude;
        float normX = 0;
        float normY = 0;
        float normZ = 0;
        if (length != 0)
        {
            normX = x / length;
            normY = y / length;
            normZ = z / length;
        }

        return Vec3f(normX, normY, normZ);
    }

    Vec3f directionTo(Vec3f other) const nothrow pure @safe
    {
        return other.subtract(this).normalize;
    }

    Vec3f clone() const nothrow pure @safe
    {
        return Vec3f(x, y, z);
    }

    alias length = magnitude;

    float magnitude() const nothrow pure @safe
    {
        return magnitudeXYZ(x, y, z);
    }

    float magnitudeSquared() const nothrow pure @safe
    {
        return magnitudeSquaredXYZ(x, y, z);
    }

    float magnitudeSquaredXYZ(float x, float y, float z) const nothrow pure @safe
    {
        return x * x + y * y + z * z;
    }

    float magnitudeXYZ(float x, float y, float z) const nothrow pure @safe
    {
        return Math.sqrt(magnitudeSquaredXYZ(x, y, z));
    }

    float distanceTo(Vec3f other) const nothrow pure @safe
    {
        return other.subtract(this).magnitude;
    }

    float manhattan(Vec3f other) const nothrow pure @safe
    {
        import Math = api.dm.math;

        return Math.abs(other.x - x) + Math.abs(other.y - y) + Math.abs(other.z - z);
    }

    float cosineSimilarity(Vec3f other) const nothrow pure @safe
    {
        import Math = api.dm.math;

        return dot(other) / (magnitude * other.magnitude);
    }

    Vec3f scale(float factor) const nothrow pure @safe
    {
        return Vec3f(x * factor, y * factor, z * factor);
    }

    Vec3f multiply(Vec3f other) const nothrow pure @safe
    {
        return Vec3f(x * other.x, y * other.y, z * other.z);
    }

    Vec3f div(float factor) const nothrow pure @safe
    {
        assert(factor != 0);
        const newX = x / factor;
        const newY = y / factor;
        const newZ = z / factor;
        return Vec3f(newX, newY, newZ);
    }

    Vec3f inc(float value) const nothrow pure @safe
    {
        return Vec3f(x + value, y + value, z + value);
    }

    Vec3f incXYZ(float xValue, float yValue, float zValue) const nothrow pure @safe
    {
        return Vec3f(x + xValue, y + yValue, z + zValue);
    }

    Vec3f decXYZ(float xValue, float yValue, float zValue) const nothrow pure @safe
    {
        return Vec3f(x - xValue, y - yValue, z - zValue);
    }

    Vec3f dec(float value) const nothrow pure @safe
    {
        return Vec3f(x - value, y - value, z - value);
    }

    Vec3f perpendicular() const nothrow pure @safe
    {
        import Math = api.dm.math;

        if (Math.abs(x) > Math.abs(y))
        {
            return Vec3f(-z, 0, x);
        }

        return Vec3f(0, z, -y);
    }

    Vec3f[2] perpendicularBasis(Vec3f other) const nothrow pure @safe
    {
        return [perpendicular, cross(other)];
    }

    Vec3f translate(float tx, float ty, float tz) const nothrow pure @safe
    {
        return Vec3f(x + tx, y + ty, z + tz);
    }

    Vec3f rotateX(float angleDeg) const nothrow pure @safe
    {
        import Math = api.dm.math;

        float ca = Math.cosDeg(angleDeg);
        float sa = Math.sinDeg(angleDeg);
        return Vec3f(
            x,
            y * ca - z * sa,
            y * sa + z * ca
        );
    }

    Vec3f rotateY(float angleDeg) const nothrow pure @safe
    {
        import Math = api.dm.math;

        float ca = Math.cosDeg(angleDeg);
        float sa = Math.sinDeg(angleDeg);
        return Vec3f(
            x * ca + z * sa,
            y,
            -x * sa + z * ca
        );
    }

    Vec3f rotateZ(float angleDeg) const nothrow pure @safe
    {
        import Math = api.dm.math;

        float ca = Math.cosDeg(angleDeg);
        float sa = Math.sinDeg(angleDeg);
        return Vec3f(
            x * ca - y * sa,
            x * sa + y * ca,
            z
        );
    }

    Vec3f rotateAroundAxis(Vec3f axis, float angleDeg) const nothrow pure @safe
    {
        import Math = api.dm.math;

        Vec3f u = axis.normalize;
        float ca = Math.cosDeg(angleDeg);
        float sa = Math.sinDeg(angleDeg);

        //Rodrigues' rotation formula
        // v_rot = v*cosθ + (u×v)*sinθ + u*(u·v)*(1-cosθ)
        return scale(ca) +
            u.cross(this).scale(sa) +
            u.scale((u.dot(this)) * (1 - ca));
    }

    Vec3f shear3D(float sxy, float sxz, float syx, float syz, float szx, float szy) const nothrow pure @safe
    {
        return Vec3f(
            x + sxy * y + sxz * z, // X from Y and Z
            y + syx * x + syz * z, // Y from X and Z  
            z + szx * x + szy * y // Z from X and Y

            

        );
    }

    Vec3f shear(float sxy, float sxz, float syx, float syz) const nothrow pure @safe
    {
        return Vec3f(
            x + sxy * y + sxz * z,
            y + syx * x + syz * z,
            z
        );
    }

    Vec3f shearXY(float sx, float sy) const nothrow pure @safe
    {
        return Vec3f(
            x + sx * y,
            y + sy * x,
            z
        );
    }

    Vec3f shearXZ(float sx, float sz) const nothrow pure @safe
    {
        return Vec3f(
            x + sx * z,
            y,
            z + sz * x
        );
    }

    Vec3f shearYZ(float sy, float sz) const nothrow pure @safe
    {
        return Vec3f(
            x,
            y + sy * z,
            z + sz * y
        );
    }

    Vec3f projectTo(Vec3f other) const nothrow pure @safe
    {
        //const norm = other.normalize;
        //const otherProject = norm.scale(this.dot(norm));
        //return otherProject;

        const otherLenSq = other.magnitudeSquared;
        if (otherLenSq == 0)
            return Vec3f(0, 0, 0);

        const scale = dot(other) / otherLenSq;
        return other.scale(scale);
    }

    float project(Vec3f other) const nothrow pure @safe
    {
        const dop = dot(other);
        const otherLen = other.length;
        return (otherLen != 0) ? dop / otherLen : 0.0f;
    }

    Vec3f project(float factor) const nothrow pure @safe
    {
        if (factor == 0)
            return Vec3f(0, 0, 0);
        return Vec3f(x / factor, y / factor, z / factor);
    }

    Vec3f projectToPlane(Vec3f planeNormal) const nothrow pure @safe
    {
        const norm = planeNormal.normalize;
        const projection = norm.scale(dot(norm));
        return subtract(projection);
    }

    Vec3f projectToPlane(Vec3f pointOnPlane, Vec3f planeNormal) const nothrow pure @safe
    {
        const norm = planeNormal.normalize;
        const vecToPoint = subtract(pointOnPlane);
        const distanceToPlane = vecToPoint.dot(norm);
        return subtract(norm.scale(distanceToPlane));
    }

    float dot(Vec3f b) const nothrow pure @safe
    {
        return x * b.x + y * b.y + z * b.z;
    }

    bool isCollinear(Vec3f other, double tolerance = 1e-9) const nothrow pure @safe
    {
        import Math = api.dm.math;

        double crossNorm = cross(other).magnitudeSquared;
        return crossNorm < tolerance;
    }

    Vec3f cross(Vec3f other) const nothrow pure @safe
    {
        return Vec3f(
            y * other.z - z * other.y,
            z * other.x - x * other.z,
            x * other.y - y * other.x
        );
    }

    float angleBetween(Vec3f other) const nothrow pure @safe
    {
        import Math = api.dm.math;

        double dotProduct = dot(other);
        double lenProduct = length * other.length;

        if (lenProduct < 1e-9)
            return 0.0f;

        double cosine = Math.clamp(dotProduct / lenProduct, -1.0, 1.0);
        return Math.acos(cosine);
    }

    float angleOnPlane(Vec3f other, Vec3f planeNormal) const nothrow pure @safe
    {
        import Math = api.dm.math;

        Vec3f proj1 = projectToPlane(planeNormal);
        Vec3f proj2 = other.projectToPlane(planeNormal);

        Vec3f basisX = proj1.normalize;
        Vec3f basisY = planeNormal.cross(basisX).normalize;

        float x1 = proj1.dot(basisX);
        float y1 = proj1.dot(basisY);
        float x2 = proj2.dot(basisX);
        float y2 = proj2.dot(basisY);

        return Math.atan2(y2, x2) - Math.atan2(y1, x1);
    }

    float pitch() const nothrow pure @safe
    {
        return Math.atan2(cast(double) y, Math.sqrt(x * x + z * z));
    }

    float yaw() const nothrow pure @safe
    {
        return Math.atan2(x, z);
    }

    float roll() const nothrow pure @safe
    {
        return Math.atan2(y, x);
    }

    SphericalCoords toSpherical() const nothrow pure @safe
    {
        float r = length;
        float theta = Math.atan2(y, x);
        float phi = Math.acos(Math.clamp(z / r, -1.0f, 1.0f));

        return SphericalCoords(r, theta, phi);
    }

    static Vec3f fromSpherical(SphericalCoords sph) nothrow pure @safe
    {
        return Vec3f(
            sph.radius * Math.sin(sph.phi) * Math.cos(sph.theta),
            sph.radius * Math.sin(sph.phi) * Math.sin(sph.theta),
            sph.radius * Math.cos(sph.phi)
        );
    }

    Vec3f reflect(Vec3f planeNormal) const nothrow pure @safe
    {
        // reflected = incident - 2 * (incident · normal) * normal
        const norm = planeNormal.normalize;
        const dotProduct = dot(norm);
        return subtract(norm.scale(2 * dotProduct));
    }

    Vec3f reflect(Vec3f pointOnPlane, Vec3f planeNormal) const nothrow pure @safe
    {
        const norm = planeNormal.normalize;
        const vecToPlane = subtract(pointOnPlane);
        const dotProduct = vecToPlane.dot(norm);
        return subtract(norm.scale(2 * dotProduct));
    }

    Vec3f reflectX() const nothrow pure @safe => Vec3f(-x, y, z);
    Vec3f reflectY() const nothrow pure @safe => Vec3f(x, -y, z);
    Vec3f reflectZ() const nothrow pure @safe => Vec3f(x, y, -z);

    Vec3f reflectAroundAxis(Vec3f axisDirection) const nothrow pure @safe
    {
        const axis = axisDirection.normalize;
        const projection = axis.scale(dot(axis));
        const perpendicular = subtract(projection);
        return projection.subtract(perpendicular);
    }

    Vec3f min(Vec3f other) const nothrow pure @safe
    {
        const newX = Math.min(x, other.x);
        const newY = Math.min(y, other.y);
        const newZ = Math.min(z, other.z);

        return Vec3f(newX, newY, newZ);
    }

    Vec3f max(Vec3f other) const nothrow pure @safe
    {
        const newX = Math.max(x, other.x);
        const newY = Math.max(y, other.y);
        const newZ = Math.max(z, other.z);

        return Vec3f(newX, newY, newZ);
    }

    void clip(float minX, float minY, float minZ, float maxX, float maxY, float maxZ)
    nothrow pure @safe
    {
        import Math = api.dm.math;

        x = Math.clamp(x, minX, maxX);
        y = Math.clamp(y, minY, maxY);
        z = Math.clamp(z, minZ, maxZ);
    }

    string toString() const
    {
        import std.format : format;

        return format("x:%.10f,y:%.10f:z%.10f", x, y, z);
    }

    void opIndexAssign(double value, size_t i) @safe
    {
        if (i == 0)
            x = value;
        else if (i == 1)
            y = value;
        else if (i == 2)
        {
            z = value;
        }
        else
        {
            import std.conv : text;

            throw new Exception(text("Invalid vector index: ", i));
        }
    }

    double opIndex(size_t i) const pure @safe
    {
        if (i == 0)
            return x;
        if (i == 1)
            return y;
        if (i == 2)
            return z;

        import std.conv : text;

        throw new Exception(text("Invalid vector index: ", i));
    }

    void opOpAssign(string op)(Vec3f other)
    {
        const otherId = __traits(identifier, other);
        mixin("x" ~ op ~ "=" ~ otherId ~ ".x;");
        mixin("y" ~ op ~ "=" ~ otherId ~ ".y;");
        mixin("z" ~ op ~ "=" ~ otherId ~ ".z;");
    }

    Vec3f opBinary(string op)(Vec3f other) const nothrow pure @safe
    {
        static if (op == "+")
            return add(other);
        else static if (op == "-")
            return subtract(other);
        else
            static assert(0, "Operator " ~ op ~ " not implemented");
    }
}
