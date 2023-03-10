module deltotum.math.matrices.matrix;

import deltotum.math.matrices.dense_matrix : DenseMatrix;

/**
 * Authors: initkfs
 */
alias Matrix2x1 = DenseMatrix!(double, 2, 1);
alias Matrix2x2 = DenseMatrix!(double, 2, 2);
alias Matrix3x3 = DenseMatrix!(double, 3, 3);

double[][] newInitMatrixD(size_t rowDim, size_t colDim) pure nothrow
{
    return newInitMatrix!double(rowDim, colDim, 0);
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

double[] newInitVectorD(size_t colDim) pure nothrow
{
    return newInitVector!double(colDim, 0);
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
