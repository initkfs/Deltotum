module api.math.quaternion;

import api.math.geom2.vec3 : Vec3f;
import api.math.matrices.matrix : Matrix4x4f;

import Math = api.math;
import api.math.matrices.matrix;

/**
 * Authors: initkfs
 */

struct Quaternion
{
    double w = 0; //Scalar
    Vec3f v; // Imaginary

    static Quaternion identity() => Quaternion(1);

    //ax*ax + ay*ay + az*az = 1
    static Quaternion fromAngle(double angleDeg, Vec3f axisNormalized)
    {
        //https://www.euclideanspace.com/maths/algebra/realNormedAlgebra/quaternions/index.htm
        const realPart = Math.cosDeg(angleDeg / 2);
        const complexPart = Math.sin(angleDeg / 2);
        return Quaternion(realPart, Vec3f(complexPart * axisNormalized.x, complexPart * axisNormalized.y, complexPart * axisNormalized
                .z));
    }

    bool toAngle(double angleDeg, ref Vec3f axis)
    {
        angleDeg = Math.radToDeg(2 * Math.acos(w));

        double divider = Math.sqrt(1 - w * w);

        if (divider != 0)
        {
            axis.x = v.x / divider;
            axis.y = v.y / divider;
            axis.z = v.z / divider;
        }
        else
        {
            axis.x = 1;
            axis.y = 0;
            axis.z = 0;
        }
        return true;
    }

    static Quaternion fromRotationX(double angleDeg) => Quaternion.fromAngle(angleDeg, Vec3f(1, 0, 0));
    static Quaternion fromRotationY(double angleDeg) => Quaternion.fromAngle(angleDeg, Vec3f(0, 1, 0));
    static Quaternion fromRotationZ(double angleDeg) => Quaternion.fromAngle(angleDeg, Vec3f(0, 0, 1));

    static Quaternion fromEuler(double angleXDeg = 0, double angleYDeg = 0, double angleZDeg = 0)
    {
        //https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles
        double cr = Math.cos(Math.degToRad(angleXDeg) * 0.5);
        double sr = Math.sin(Math.degToRad(angleXDeg) * 0.5);
        double cp = Math.cos(Math.degToRad(angleYDeg) * 0.5);
        double sp = Math.sin(Math.degToRad(angleYDeg) * 0.5);
        double cy = Math.cos(Math.degToRad(angleZDeg) * 0.5);
        double sy = Math.sin(Math.degToRad(angleZDeg) * 0.5);

        Quaternion q;
        q.w = cr * cp * cy + sr * sp * sy;
        q.v.x = sr * cp * cy - cr * sp * sy;
        q.v.y = cr * sp * cy + sr * cp * sy;
        q.v.z = cr * cp * sy - sr * sp * cy;

        return q;
    }

    Vec3f toEuler()
    {
        // roll (x-axis)
        double a = 2 * (w * v.x + v.y * v.z);
        double b = 1 - 2 * (v.x * v.x + v.y * v.y);
        auto rollRad = Math.atan2(a, b);

        // pitch (y-axis)
        double c = Math.sqrt(1 + 2 * (w * v.y - v.x * v.z));
        double d = Math.sqrt(1 - 2 * (w * v.y - v.x * v.z));
        auto pitchRad = 2 * Math.atan2(c, d) - Math.PI / 2;

        // yaw (z-axis rotation)
        double e = 2 * (w * v.z + v.x * v.y);
        double f = 1 - 2 * (v.y * v.y + v.z * v.z);
        auto yawRad = Math.atan2(e, f);

        return Vec3f(Math.radToDeg(rollRad), Math.radToDeg(pitchRad), Math.radToDeg(yawRad));
    }

    double length() => Math.sqrt(w * w + v.x * v.x + v.y * v.y + v.z * v.z);

    Quaternion normalize()
    {
        const len = length;
        return Quaternion(w / len, Vec3f(v.x / len, v.y / len, v.z / len));
    }

    Quaternion mul(Quaternion other)
    {
        Quaternion result;
        // Scalar part: w1*w2 - v1·v2 (dot product)
        result.w = w * other.w - v.dot(other.v);
        // Vector part: w1*v2 + w2*v1 + v1×v2 (cross product)
        result.v = other.v.scale(w) + v.scale(other.w) + v.cross(other.v);
        return result;
    }

    Vec3f rotate(Vec3f v)
    {
        //v' = q * v * q⁻¹
        double ww = w * w;
        double xx = v.x * v.x;
        double yy = v.y * v.y;
        double zz = v.z * v.z;
        double wx = w * v.x;
        double wy = w * v.y;
        double wz = w * v.z;
        double xy = v.x * v.y;
        double xz = v.x * v.z;
        double yz = v.y * v.z;

        return Vec3f(
            v.x * (ww + xx - yy - zz) + 2 * (xy * v.y + xz * v.z + wy * v.z - wz * v.y),
            v.y * (ww - xx + yy - zz) + 2 * (xy * v.x + yz * v.z + wz * v.x - wx * v.z),
            v.z * (ww - xx - yy + zz) + 2 * (xz * v.x + yz * v.y + wx * v.y - wy * v.x)
        );
    }

    // Spherical Linear Interpolation between two quaternions
    Quaternion slerp(Quaternion from, Quaternion to, double t)
    {
        //https://www.euclideanspace.com/maths/algebra/realNormedAlgebra/quaternions/slerp/index.htm
        Quaternion result;

        double cosHalfTheta = from.w * to.w + from.v.x * to.v.x + from.v.y * to.v.y + from.v.z * to
            .v.z;

        if (Math.abs(cosHalfTheta) >= 1.0)
        {
            result.w = from.w;
            result.v.x = from.v.x;
            result.v.y = from.v.y;
            result.v.z = from.v.z;
            return result;
        }

        double halfTheta = Math.acos(cosHalfTheta);
        double sinHalfTheta = Math.sqrt(1.0 - cosHalfTheta * cosHalfTheta);

        // if theta  180 degrees then result is not fully defined we could rotate around any axis normal to from or to
        if (Math.abs(sinHalfTheta) < 0.001)
        {
            result.w = (from.w * 0.5 + to.w * 0.5);
            result.v.x = (from.v.x * 0.5 + to.v.x * 0.5);
            result.v.y = (from.v.y * 0.5 + to.v.y * 0.5);
            result.v.z = (from.v.z * 0.5 + to.v.z * 0.5);
            return result;
        }

        double ratioA = Math.sin((1 - t) * halfTheta) / sinHalfTheta;
        double ratioB = Math.sin(t * halfTheta) / sinHalfTheta;

        result.w = (from.w * ratioA + to.w * ratioB);
        result.v.x = (from.v.x * ratioA + to.v.x * ratioB);
        result.v.y = (from.v.y * ratioA + to.v.y * ratioB);
        result.v.z = (from.v.z * ratioA + to.v.z * ratioB);

        return result;
    }

    /// Normalized Linear Interpolation (faster approximation)
    Quaternion nlerp(Quaternion from, Quaternion to, double t)
    {
        Quaternion result = Quaternion(
            from.w * (1 - t) + to.w * t,
            Vec3f(from.v.x * (1 - t) + to.v.x * t,
                from.v.y * (1 - t) + to.v.y * t,
                from.v.z * (1 - t) + to.v.z * t)
        );
        return result.normalize;
    }

    Matrix4x4f toMatrix4x4LH()
    {

        Matrix4x4f mat;
        Quaternion q = normalize();

        double xx = q.v.x * q.v.x;
        double yy = q.v.y * q.v.y;
        double zz = q.v.z * q.v.z;
        double xy = q.v.x * q.v.y;
        double xz = q.v.x * q.v.z;
        double yz = q.v.y * q.v.z;
        double wx = q.w * q.v.x;
        double wy = q.w * q.v.y;
        double wz = q.w * q.v.z;

        // Для левосторонней системы с инвертированным Z:
        mat[0][0] = 1.0 - 2.0 * (yy + zz);
        mat[0][1] = 2.0 * (xy + wz); // ИЗМЕНЕНО: +wz вместо -wz
        mat[0][2] = 2.0 * (xz - wy); // ИЗМЕНЕНО: -wy вместо +wy
        mat[0][3] = 0;

        mat[1][0] = 2.0 * (xy - wz); // ИЗМЕНЕНО: -wz вместо +wz
        mat[1][1] = 1.0 - 2.0 * (xx + zz);
        mat[1][2] = 2.0 * (yz + wx); // ИЗМЕНЕНО: +wx вместо -wx
        mat[1][3] = 0.0;

        mat[2][0] = 2.0 * (xz + wy); // ИЗМЕНЕНО: +wy вместо -wy
        mat[2][1] = 2.0 * (yz - wx); // ИЗМЕНЕНО: -wx вместо +wx
        mat[2][2] = 1.0 - 2.0 * (xx + yy);
        mat[2][3] = 0.0;

        mat[3][0] = 0.0;
        mat[3][1] = 0.0;
        mat[3][2] = 0.0;
        mat[3][3] = 1.0;

        return mat;
    }

    Matrix4x4f toMatrix4x4RH()
    {
        Matrix4x4f mat;

        Quaternion q = normalize;

        double xx = q.v.x * q.v.x;
        double yy = q.v.y * q.v.y;
        double zz = q.v.z * q.v.z;
        double xy = q.v.x * q.v.y;
        double xz = q.v.x * q.v.z;
        double yz = q.v.y * q.v.z;
        double wx = q.w * q.v.x;
        double wy = q.w * q.v.y;
        double wz = q.w * q.v.z;

        mat[0][0] = 1.0 - 2.0 * (yy + zz);
        mat[0][1] = 2.0 * (xy - wz);
        mat[0][2] = 2.0 * (xz + wy);
        mat[0][3] = 0;

        mat[1][0] = 2.0 * (xy + wz);
        mat[1][1] = 1.0 - 2.0 * (xx + zz);
        mat[1][2] = 2.0 * (yz - wx);
        mat[1][3] = 0.0;

        mat[2][0] = 2.0 * (xz - wy);
        mat[2][1] = 2.0 * (yz + wx);
        mat[2][2] = 1.0 - 2.0 * (xx + yy);
        mat[2][3] = 0.0;

        mat[3][0] = 0.0;
        mat[3][1] = 0.0;
        mat[3][2] = 0.0;
        mat[3][3] = 1.0;

        return mat;
    }

}

unittest
{
    import std.math.operations : isClose;

    double eps = 0.00001;
    Quaternion q1 = Quaternion.fromEuler(90, 120, 270);
    assert(isClose(q1.w, 0.1830127, eps));
    assert(isClose(q1.v.x, -0.6830127, eps));
    assert(isClose(q1.v.y, -0.1830127, eps));
    assert(isClose(q1.v.z, 0.6830127, eps));
}

// unittest
// {
//     import std.math.operations : isClose;

//     const double eps = 0.0000001;

//     Quaternion qt;
//     auto qtAngle = qt.fromAngle(90, Vec3f(1, 0, 0));
//     assert(isClose(qtAngle.w, 0.701, eps));
//     assert(isClose(qtAngle.x, 0.701, eps));
//     assert(isClose(qtAngle.y, 0, 0, eps));
//     assert(isClose(qtAngle.z, 0, 0, eps));
// }
