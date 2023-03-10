module deltotum.maths.matrices.decompose.cholesky;

import deltotum.maths.matrices.dense_matrix : DenseMatrix;
import Math = deltotum.maths.math;

/**
 * Authors: initkfs
 *
 * Part of the calculations ported from the JAMA library, Public Domain License: https://math.nist.gov/javanumerics/jama
 * 
 */
struct Cholesky(T = double, size_t RowDim, size_t ColDim)
        if (RowDim >= 1 && ColDim >= 1 && RowDim == ColDim)
{
    T[ColDim][RowDim] matrix;
    bool isSymmetricPositive;
}

/** 
 * https://en.wikipedia.org/wiki/Cholesky_decomposition
 */
Cholesky!(T, RowDim, ColDim) decompose(T = double, size_t RowDim, size_t ColDim)(
    ref DenseMatrix!(T, RowDim, ColDim) matrix)
        if (RowDim > 0 && ColDim > 0 && RowDim == ColDim)
{
    typeof(return) result;
    //true if RowDim == ColDim
    result.isSymmetricPositive = true;

    foreach (j; 0 .. RowDim)
    {
        double[] Lrowj = result.matrix[j];
        double d = 0.0;
        foreach (k; 0 .. j)
        {
            double[] Lrowk = result.matrix[k];
            double s = 0.0;
            foreach (i; 0 .. k)
            {
                s += Lrowk[i] * Lrowj[i];
            }
            Lrowj[k] = s = (matrix[j][k] - s) / result.matrix[k][k];
            d = d + s * s;
            result.isSymmetricPositive = result.isSymmetricPositive && (matrix[k][j] == matrix[j][k]);
        }
        d = matrix[j][j] - d;
        result.isSymmetricPositive = result.isSymmetricPositive && (d > 0);
        result.matrix[j][j] = Math.sqrt(Math.max(d, 0.0));
        foreach (k; j + 1 .. RowDim)
        {
            result.matrix[j][k] = 0.0;
        }
    }
    return result;
}

/** 
 * L*L'*X = B
 */
DenseMatrix!(T, RowDim, 1) solve(T = double, size_t RowDim, size_t ColDim)(
    ref Cholesky!(T, RowDim, ColDim) cholesky, double[] B)
        if (RowDim >=1 && ColDim >= 1 && RowDim == ColDim)
{
    if (!cholesky.isSymmetricPositive)
    {
        throw new Exception("Matrix is not symmetric positive definite.");
    }

    if(B.length != cholesky.matrix.length){
        throw new Exception("Matrix row dimensions must agree.");
    }

    typeof(return) result;
    foreach (i, ref row; result.matrix)
    {
        row[] = B[i];
    }

    //B column dimension
    size_t nx = 1;

    // Solve L*Y = B;
    foreach(k; 0..RowDim)
    {
        foreach(j; 0..nx)
        {
            foreach(i; 0..k)
            {
                result[k][j] -= result[i][j] * cholesky.matrix[k][i];
            }
            result[k][j] /= cholesky.matrix[k][k];
        }
    }

    // Solve L'*X = Y;
    foreach_reverse(k; 0..RowDim)
    {
        foreach(j; 0..nx)
        {
            foreach(i; k + 1..RowDim)
            {
                result[k][j] -= result[i][j] * cholesky.matrix[i][k];
            }
            result[k][j] /= cholesky.matrix[k][k];
        }
    }
    return result;
}

unittest
{
    import std.math.operations : isClose;
    import std.algorithm.comparison : equal;
    import deltotum.maths.matrices.dense_matrix : DenseMatrix;

    auto m1 = DenseMatrix!(double, 3, 3)([
        [4, 12, -16],
        [12, 37, -43],
        [-16, -43, 98],
    ]);

    auto m1result = decompose!(double, 3, 3)(m1);

    assert(equal!isClose(m1result.matrix[0][], [2.0, 0, 0]));
    assert(equal!isClose(m1result.matrix[1][], [6.0, 1, 0]));
    assert(equal!isClose(m1result.matrix[2][], [-8.0, 5, 3]));

    //4x + 10y + 8z = 44
    //10x + 26y + 26z = 128
    //8x + 26y + 61z = 214
    auto m2 = DenseMatrix!(double, 3, 3)([
        [4, 10, 8],
        [10, 26, 26],
        [8, 26, 61],
    ]);

    auto m3Result = decompose!(double, 3, 3)(m2);
    auto m3SolveResult = solve(m3Result, [44, 128, 214]);
    assert(m3SolveResult[0] == [-8]);
    assert(m3SolveResult[1] == [6]);
    assert(m3SolveResult[2] == [2]);
}