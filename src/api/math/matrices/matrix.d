module api.math.matrices.matrix;

import api.math.matrices.dense_matrix : DenseMatrix;
import api.math.geom2.vec2 : Vec2f;

/**
 * Authors: initkfs
 */
alias Matrix2x1 = DenseMatrix!(float, 2, 1);
alias Matrix2x2 = DenseMatrix!(float, 2, 2);
alias Matrix3x3 = DenseMatrix!(float, 3, 3);
alias Matrix4x4 = DenseMatrix!(float, 4, 4);
alias Matrix3x1 = DenseMatrix!(float, 3, 1);

Vec2f toVec2f(ref Matrix2x1 m) => Vec2f(m[0][0], m[1][0]);
Vec2f toVec2f(Matrix2x1 m) => Vec2f(m[0][0], m[1][0]);
void fromVec2f(ref Matrix2x1 m, Vec2f vec)
{
    m[0][0] = vec.x;
    m[1][0] = vec.y;
}

float[][] newInitMatrixD(size_t rowDim, size_t colDim) pure nothrow
{
    return newInitMatrix!float(rowDim, colDim, 0);
}

//TODO constraints
T[][] newInitMatrix(T, I)(size_t rowDim, size_t colDim, I initValue) pure nothrow
{
    if (rowDim == 0 || colDim == 0)
    {
        return [];
    }

    import std.array : uninitializedArray;

    auto result = uninitializedArray!(typeof(return))(rowDim, colDim);
    foreach (ref row; result)
    {
        row[] = initValue;
    }
    return result;
}

float[] newInitVectorD(size_t colDim) pure nothrow
{
    return newInitVector!float(colDim, 0);
}

T[] newInitVector(T, I)(size_t colDim, I initValue) pure nothrow
{
    if (colDim == 0)
    {
        return [];
    }

    import std.array : uninitializedArray;

    auto result = uninitializedArray!(typeof(return))(colDim);
    result[] = initValue;
    return result;
}

Matrix4x4 inverse(ref Matrix4x4 m, out bool isSuccess)
{
    typeof(return) result;

    //TODO disable bounds
    const s0 = m[0, 0] * m[1, 1] - m[1, 0] * m[0, 1];
    const s1 = m[0, 0] * m[1, 2] - m[1, 0] * m[0, 2];
    const s2 = m[0, 0] * m[1, 3] - m[1, 0] * m[0, 3];
    const s3 = m[0, 1] * m[1, 2] - m[1, 1] * m[0, 2];
    const s4 = m[0, 1] * m[1, 3] - m[1, 1] * m[0, 3];
    const s5 = m[0, 2] * m[1, 3] - m[1, 2] * m[0, 3];

    const c5 = m[2, 2] * m[3, 3] - m[3, 2] * m[2, 3];
    const c4 = m[2, 1] * m[3, 3] - m[3, 1] * m[2, 3];
    const c3 = m[2, 1] * m[3, 2] - m[3, 1] * m[2, 2];
    const c2 = m[2, 0] * m[3, 3] - m[3, 0] * m[2, 3];
    const c1 = m[2, 0] * m[3, 2] - m[3, 0] * m[2, 2];
    const c0 = m[2, 0] * m[3, 1] - m[3, 0] * m[2, 1];

    const det = s0 * c5 - s1 * c4 + s2 * c3 + s3 * c2 - s4 * c1 + s5 * c0;
    if (det == 0)
    {
        //singular
        isSuccess = false;
        return result;
    }

    const invdet = 1.0 / det;

    result[0, 0] = (m[1, 1] * c5 - m[1, 2] * c4 + m[1, 3] * c3) * invdet;
    result[0, 1] = (-m[0, 1] * c5 + m[0, 2] * c4 - m[0, 3] * c3) * invdet;
    result[0, 2] = (m[3, 1] * s5 - m[3, 2] * s4 + m[3, 3] * s3) * invdet;
    result[0, 3] = (-m[2, 1] * s5 + m[2, 2] * s4 - m[2, 3] * s3) * invdet;

    result[1, 0] = (-m[1, 0] * c5 + m[1, 2] * c2 - m[1, 3] * c1) * invdet;
    result[1, 1] = (m[0, 0] * c5 - m[0, 2] * c2 + m[0, 3] * c1) * invdet;
    result[1, 2] = (-m[3, 0] * s5 + m[3, 2] * s2 - m[3, 3] * s1) * invdet;
    result[1, 3] = (m[2, 0] * s5 - m[2, 2] * s2 + m[2, 3] * s1) * invdet;

    result[2, 0] = (m[1, 0] * c4 - m[1, 1] * c2 + m[1, 3] * c0) * invdet;
    result[2, 1] = (-m[0, 0] * c4 + m[0, 1] * c2 - m[0, 3] * c0) * invdet;
    result[2, 2] = (m[3, 0] * s4 - m[3, 1] * s2 + m[3, 3] * s0) * invdet;
    result[2, 3] = (-m[2, 0] * s4 + m[2, 1] * s2 - m[2, 3] * s0) * invdet;

    result[3, 0] = (-m[1, 0] * c3 + m[1, 1] * c1 - m[1, 2] * c0) * invdet;
    result[3, 1] = (m[0, 0] * c3 - m[0, 1] * c1 + m[0, 2] * c0) * invdet;
    result[3, 2] = (-m[3, 0] * s3 + m[3, 1] * s1 - m[3, 2] * s0) * invdet;
    result[3, 3] = (m[2, 0] * s3 - m[2, 1] * s1 + m[2, 2] * s0) * invdet;

    isSuccess = true;

    return result;
}

unittest
{
    import std.math.operations : isClose;
    import std.algorithm.comparison : equal;

    auto m1 = Matrix4x4([
        [2, 7, 6, 2],
        [9, 5, 1, 3],
        [4, 3, 8, 4],
        [5, 6, 7, 8],
    ]);

    bool isResult;
    auto invResult = inverse(m1, isResult);
    assert(isResult);

    assert(equal!isClose(invResult[0], [
        -0.0625, 0.125, 0.1041666666, -0.0833333333
    ]));
    assert(equal!isClose(invResult[1], [
        0.1742424242, 0.01515151515, -0.15909090909, 0.0303030303
    ]));
    assert(equal!isClose(invResult[2], [
        0.02083333333, -0.04166666666, 0.1875, -0.0833333333
    ]));
    assert(equal!isClose(invResult[3], [
        -0.1098484848, -0.053030303, -0.10984848484, 0.2272727272
    ]));
}
