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
