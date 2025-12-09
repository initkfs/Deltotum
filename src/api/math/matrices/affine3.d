module api.math.matrices.affine3;

import api.math.matrices.matrix;
import api.math.geom2.vec2 : Vec2d;
import api.math.geom3.vec3 : Vec3f;

import Math = api.math;

/**
 * Authors: initkfs
   Projection × View × Model × Vertex
   translate * rotate * scale
   scale-> rotate -> translate
 */

Matrix4x4f rotateMatrixX(float angleDeg)
{
    import Math = api.math;

    Matrix4x4f matrix;

    float angleRad = Math.degToRad(angleDeg);

    float cosA = Math.cos(angleRad);
    float sinA = Math.sin(angleRad);

    matrix[0][0] = 1;
    matrix[0][1] = 0;
    matrix[0][2] = 0;
    matrix[0][3] = 0;
    matrix[1][0] = 0;
    matrix[1][1] = cosA;
    matrix[1][2] = -sinA;
    matrix[1][3] = 0;
    matrix[2][0] = 0;
    matrix[2][1] = sinA;
    matrix[2][2] = cosA;
    matrix[2][3] = 0;
    matrix[3][0] = 0;
    matrix[3][1] = 0;
    matrix[3][2] = 0;
    matrix[3][3] = 1;

    return matrix;
}

Matrix4x4f rotateMatrixY(float angleDeg)
{
    import Math = api.math;

    Matrix4x4f matrix;

    float angleRad = Math.degToRad(angleDeg);

    float cosA = Math.cos(angleRad);
    float sinA = Math.sin(angleRad);

    matrix[0][0] = cosA;
    matrix[0][1] = 0;
    matrix[0][2] = sinA;
    matrix[0][3] = 0;
    matrix[1][0] = 0;
    matrix[1][1] = 1;
    matrix[1][2] = 0;
    matrix[1][3] = 0;
    matrix[2][0] = -sinA;
    matrix[2][1] = 0;
    matrix[2][2] = cosA;
    matrix[2][3] = 0;
    matrix[3][0] = 0;
    matrix[3][1] = 0;
    matrix[3][2] = 0;
    matrix[3][3] = 1;

    return matrix;
}

Matrix4x4f rotateMatrixZ(float angleDeg)
{
    import Math = api.math;

    Matrix4x4f matrix;

    float angleRad = Math.degToRad(angleDeg);

    float cosA = Math.cos(angleRad);
    float sinA = Math.sin(angleRad);

    matrix[0][0] = cosA;
    matrix[0][1] = -sinA;
    matrix[0][2] = 0;
    matrix[0][3] = 0;
    matrix[1][0] = sinA;
    matrix[1][1] = cosA;
    matrix[1][2] = 0;
    matrix[1][3] = 0;
    matrix[2][0] = 0;
    matrix[2][1] = 0;
    matrix[2][2] = 1;
    matrix[2][3] = 0;
    matrix[3][0] = 0;
    matrix[3][1] = 0;
    matrix[3][2] = 0;
    matrix[3][3] = 1;

    return matrix;
}

Matrix4x4f rotateMatrix(float angleDeg, Vec3f angles) => rotateMatrix(angleDeg, angles.x, angles.y, angles
        .z);

Matrix4x4f rotateMatrix(float angleDeg, float axisX, float axisY, float axisZ)
{
    //auto rotX = rotateMatrix(45.0f, 1.0f, 0.0f, 0.0f);
    import Math = api.math;

    Matrix4x4f matrix;
    matrix.fillInit;

    float angleRad = Math.degToRad(angleDeg);

    float cosA = Math.cos(angleRad);
    float sinA = Math.sin(angleRad);

    float oneMinusCosA = 1.0f - cosA;

    float length = Math.sqrt(axisX * axisX + axisY * axisY + axisZ * axisZ);
    float x = axisX / length;
    float y = axisY / length;
    float z = axisZ / length;

    matrix[0][0] = cosA + x * x * oneMinusCosA;
    matrix[0][1] = x * y * oneMinusCosA - z * sinA;
    matrix[0][2] = x * z * oneMinusCosA + y * sinA;
    matrix[0][3] = 0;

    matrix[1][0] = y * x * oneMinusCosA + z * sinA;
    matrix[1][1] = cosA + y * y * oneMinusCosA;
    matrix[1][2] = y * z * oneMinusCosA - x * sinA;
    matrix[1][3] = 0;

    matrix[2][0] = z * x * oneMinusCosA - y * sinA;
    matrix[2][1] = z * y * oneMinusCosA + x * sinA;
    matrix[2][2] = cosA + z * z * oneMinusCosA;
    matrix[2][3] = 0;

    matrix[3][0] = 0;
    matrix[3][1] = 0;
    matrix[3][2] = 0;
    matrix[3][3] = 1;

    return matrix;
}

Matrix4x4f combinedRotation(float pitchX, float yawY, float rollZ)
{
    //XYZ 
    //row vector XYZ
    //±90° parallel axis, ex, pitch = 90°, cos(pitch) = 0, sin(pitch) = 1
    /** 
     * XYZ - lock pitch = ±90°
       YZX - lock yaw = ±90°
       ZXY - lock roll = ±90°
     */
    Matrix4x4f current = Matrix4x4f.onesDiag;
    if (pitchX != 0)
    {
        Matrix4x4f rotX = rotateMatrix(pitchX, 1, 0, 0); // Pitch, X
        current = current.mul(rotX);
    }

    if (yawY != 0)
    {
        Matrix4x4f rotY = rotateMatrix(yawY, 0, 1, 0); // Yaw, Y 
        current = current.mul(rotY);
    }

    if (rollZ != 0)
    {
        Matrix4x4f rotZ = rotateMatrix(rollZ, 0, 0, 1); // Roll, Z
        current = current.mul(rotZ);
    }

    // row-major: M_roll * M_pitch * M_yaw
    return current;
}

Matrix4x4f translateMatrix(Vec3f offsets) => translateMatrix(offsets.x, offsets.y, offsets.z);

Matrix4x4f translateMatrix(float offsetX, float offsetY, float offsetZ)
{
    //row-order
    import Math = api.math;

    Matrix4x4f matrix;
    matrix.fillInit;

    matrix[0][0] = 1;
    matrix[0][3] = 0;
    matrix[1][1] = 1;
    matrix[1][3] = 0;
    matrix[2][2] = 1;
    matrix[2][3] = 0;

    matrix[3][0] = offsetX;
    matrix[3][1] = offsetY;
    matrix[3][2] = offsetZ;
    matrix[3][3] = 1;

    return matrix;
}

Matrix4x4f scaleMatrix(Vec3f vec) => scaleMatrix(vec.x, vec.y, vec.z);

Matrix4x4f scaleMatrix(float scaleX, float scaleY, float scaleZ)
{
    import Math = api.math;

    Matrix4x4f matrix;
    matrix.fillInit;

    matrix[0][0] = scaleX;
    matrix[1][1] = scaleY;
    matrix[2][2] = scaleZ;
    matrix[3][3] = 1;

    return matrix;
}

/** 
* https://learn.microsoft.com/en-en/windows/win32/direct3d9/d3dxmatrixperspectivefovrh
 * xScale     0          0              0
   0        yScale       0              0
   0        0        zf/(zn-zf)        -1
   0        0        zn*zf/(zn-zf)      0 
 */
Matrix4x4f perspectiveMatrixRH(float fovYDeg, float aspectRatio, float nearZ = 0.1, float farZ = 100)
{
    import Math = api.math;

    Matrix4x4f matrix;
    matrix.fillInit;

    float fovYRad = Math.degToRad(fovYDeg);
    float tanHalfFov = Math.tan(fovYRad * 0.5f);
    float f = 1.0f / tanHalfFov;

    matrix[0][0] = f / aspectRatio;
    matrix[1][1] = f;
    matrix[2][2] = farZ / (nearZ - farZ);
    matrix[2][3] = -1.0f;
    matrix[3][2] = (nearZ * farZ) / (nearZ - farZ);

    return matrix;
}

Matrix4x4f lookAt(Vec3f eye, Vec3f target, Vec3f up)
{
    import Math = api.math;

    Vec3f toTarget = eye.sub(target);

    Vec3f va = toTarget.normalize;
    Vec3f vb = up.cross(va).normalize;
    Vec3f vc = va.cross(vb);

    Matrix4x4f view;
    view.fillInit;

    view[0][0] = vb.x;
    view[0][1] = vc.x;
    view[0][2] = va.x;

    view[1][0] = vb.y;
    view[1][1] = vc.y;
    view[1][2] = va.y;

    view[2][0] = vb.z;
    view[2][1] = vc.z;
    view[2][2] = va.z;

    view[3][0] = -vb.dot(eye);
    view[3][1] = -vc.dot(eye);
    view[3][2] = -va.dot(eye);
    view[3][3] = 1;

    return view;
}
