module api.math.matrices.affine2;

import api.math.matrices.matrix;
import api.math.geom2.vec2 : Vec2d;

/**
 * Authors: initkfs
 */

Matrix3x1 posMatrix(Vec2d pos, double defaultNorm = 1)
{
    Matrix3x1 matrix;
    matrix[0][0] = pos.x;
    matrix[1][0] = pos.y;
    matrix[2][0] = defaultNorm;
    return matrix;
}

Vec2d mul2Affine(in Matrix3x3 m1, in Matrix3x1 m2) @safe
{
    auto result = m1.mul(m2);
    return Vec2d(result[0][0], result[1][0]);
}

Matrix3x3 identity()
{
    Matrix3x3 matrix;
    matrix[0][0] = 1;
    matrix[0][1] = 0;
    matrix[0][2] = 0;

    matrix[1][0] = 0;
    matrix[1][1] = 1;
    matrix[1][2] = 0;

    matrix[2][0] = 0;
    matrix[2][1] = 0;
    matrix[2][2] = 1;
    return matrix;
}

Matrix3x3 transMatrix(Vec2d pos)
{
    Matrix3x3 matrix;
    matrix[0][0] = 1;
    matrix[0][1] = 0;
    matrix[0][2] = pos.x;

    matrix[1][0] = 0;
    matrix[1][1] = 1;
    matrix[1][2] = pos.y;

    matrix[2][0] = 0;
    matrix[2][1] = 0;
    matrix[2][2] = 1;
    return matrix;
}

Vec2d translate(Vec2d pos, Vec2d trans) => mul2Affine(transMatrix(pos), posMatrix(trans));

Matrix3x3 scaleMatrix(Vec2d pos)
{
    Matrix3x3 matrix;
    matrix[0][0] = pos.x;
    matrix[0][1] = 0;
    matrix[0][2] = 0;

    matrix[1][0] = 0;
    matrix[1][1] = pos.y;
    matrix[1][2] = 0;

    matrix[2][0] = 0;
    matrix[2][1] = 0;
    matrix[2][2] = 1;
    return matrix;
}

Vec2d scale(Vec2d pos, Vec2d factor) => mul2Affine(scaleMatrix(pos), posMatrix(factor));

Matrix3x3 rotateMatrix(double angleDeg)
{
    import Math = api.math;

    Matrix3x3 matrix;
    matrix[0][0] = Math.cosDeg(angleDeg);
    matrix[0][1] = -Math.sinDeg(angleDeg);
    matrix[0][2] = 0;

    matrix[1][0] = Math.sinDeg(angleDeg);
    matrix[1][1] = Math.cosDeg(angleDeg);
    matrix[1][2] = 0;

    matrix[2][0] = 0;
    matrix[2][1] = 0;
    matrix[2][2] = 1;

    return matrix;
}

Vec2d rotate(Vec2d pos, double angleDeg) => mul2Affine(rotateMatrix(angleDeg), posMatrix(pos));

Matrix3x3 shearMatrix(double k)
{
    import Math = api.math;

    Matrix3x3 matrix;
    matrix[0][0] = 1;
    matrix[0][1] = k;
    matrix[0][2] = 0;

    matrix[1][0] = 0;
    matrix[1][1] = 1;
    matrix[1][2] = 0;

    matrix[2][0] = 0;
    matrix[2][1] = 0;
    matrix[2][2] = 1;
    return matrix;
}

Matrix3x3 shearMatrix(double angleDegX, double angleDegY)
{
    import Math = api.math;

    Matrix3x3 matrix;
    matrix[0][0] = 1;
    matrix[0][1] = Math.tanDeg(angleDegX);
    matrix[0][2] = 0;

    matrix[1][0] = Math.tanDeg(angleDegY);
    matrix[1][1] = 1;
    matrix[1][2] = 0;

    matrix[2][0] = 0;
    matrix[2][1] = 0;
    matrix[2][2] = 1;

    return matrix;
}

Vec2d shear(Vec2d pos, double angleDegX, double angleDegY) => mul2Affine(
    shearMatrix(angleDegX, angleDegY), posMatrix(pos));

Matrix3x3 reflectMatrix(double x, double y)
{
    Matrix3x3 matrix;
    matrix[0][0] = x;
    matrix[0][1] = 0;
    matrix[0][2] = 0;

    matrix[1][0] = 0;
    matrix[1][1] = y;
    matrix[1][2] = 0;

    matrix[2][0] = 0;
    matrix[2][1] = 0;
    matrix[2][2] = 1;
    return matrix;
}

Matrix3x3 reflectOriginMatrix() => reflectMatrix(-1, -1);
Matrix3x3 reflectXMatrix() => reflectMatrix(1, -1);
Matrix3x3 reflectYMatrix() => reflectMatrix(-1, 1);

Vec2d reflectXY(Vec2d pos) => mul2Affine(reflectOriginMatrix, posMatrix(pos));

unittest
{
    import std.math.operations : isClose;

    const double eps = 0.0001;

    const origin = Vec2d(4.6, 16.9);

    const trans1 = translate(origin, Vec2d(19, 20));
    assert(isClose(trans1.x, 23.6, eps));
    assert(isClose(trans1.y, 36.9, eps));

    const scale1 = scale(origin, Vec2d(3, 5));
    assert(isClose(scale1.x, 13.8, eps));
    assert(isClose(scale1.y, 84.5, eps));

    const refXY = reflectXY(origin);
    assert(isClose(refXY.x, -4.6, eps));
    assert(isClose(refXY.y, -16.9, eps));

    const rot1 = rotate(origin, 35);
    assert(isClose(rot1.x, -5.9253, eps));
    assert(isClose(rot1.y, 16.4821, eps));

    const shear1 = shear(origin, 8, 10);
    assert(isClose(shear1.x, 6.9751, eps));
    assert(isClose(shear1.y, 17.7111, eps));

    //reflect -> scale -> translate -> rotate
    auto resultAll = rotateMatrix(35) * shearMatrix(8, 10) * transMatrix(Vec2d(19, 20)) * scaleMatrix(Vec2d(3, 5)) * (
        reflectOriginMatrix * posMatrix(origin));
    assert(isClose(resultAll[0][0], 33.3038, eps));
    assert(isClose(resultAll[1][0], -54.301, eps));
}
