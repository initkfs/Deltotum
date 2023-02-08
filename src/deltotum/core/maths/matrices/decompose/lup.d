module deltotum.core.maths.matrices.decompose.lup;

import deltotum.core.maths.matrices.fixed_array_matrix : FixedArrayMatrix;

/**
 * Authors: initkfs
 * Part of the calculations ported from the JAMA library, Public Domain License: https://math.nist.gov/javanumerics/jama
 * 
 */
struct LUP(T = double, size_t RowDim, size_t ColDim)
{
    T[ColDim][RowDim] LU;
    //indexes where permutation matrix has "1"
    size_t[RowDim + 1] permVec;
}

/** 
 * https://en.wikipedia.org/wiki/LU_decomposition
 */
LUP!(T, RowDim, ColDim) decompose(T = double, size_t RowDim, size_t ColDim)(
    ref FixedArrayMatrix!(T, RowDim, ColDim) matrix) if (RowDim == ColDim)
{
    LUP!(T, RowDim, ColDim) result;

    if (matrix.isEmpty)
    {
        return result;
    }

    matrix.eachRow((rowIndex, row) { result.LU[rowIndex][] = row; return true; });

    immutable size_t matrixDim = RowDim;

    foreach (i; 0 .. result.permVec.length)
    {
        result.permVec[i] = i;
    }

    import math = core.math;

    enum tolerance = 1e-6;
    scope double[] temp;
    size_t j;

    foreach (i; 0 .. matrixDim)
    {
        double maxLU = 0.0;
        size_t imax = i;

        foreach (k; i .. matrixDim)
        {
            double absLU = math.fabs(result.LU[k][i]);
            if (absLU > maxLU)
            {
                maxLU = absLU;
                imax = k;
            }
        }

        if (maxLU < tolerance)
        {
            break;
        }

        if (imax != i)
        {
            j = result.permVec[i];
            result.permVec[i] = result.permVec[imax];
            result.permVec[imax] = j;

            temp = result.LU[i].dup;
            result.LU[i][] = result.LU[imax];
            result.LU[imax][] = temp;

            result.permVec[matrixDim]++;
        }

        for (j = i + 1; j < matrixDim; j++)
        {
            result.LU[j][i] /= result.LU[i][i];

            foreach (k; i + 1 .. matrixDim)
            {
                result.LU[j][k] -= result.LU[j][i] * result.LU[i][k];
            }
        }
    }

    return result;
}

/* 
 * solution of A*x=b
 * TODO return FixedArrayMatrix, remove memory allocation
 */
double[] solve(T = double, size_t RowDim, size_t ColDim)(ref LUP!(T, RowDim, ColDim) lupResult, double[] b)
{
    double[] x = new double[](b.length);
    foreach (i; 0 .. RowDim)
    {
        x[i] = b[lupResult.permVec[i]];

        foreach (k; 0 .. i)
        {
            x[i] -= lupResult.LU[i][k] * x[k];
        }
    }

    foreach_reverse (i; 0 .. RowDim)
    {
        foreach (k; (i + 1) .. RowDim)
        {
            x[i] -= lupResult.LU[i][k] * x[k];
        }
        x[i] /= lupResult.LU[i][i];
    }

    return x;
}

FixedArrayMatrix!(T, RowDim, ColDim) invert(T = double, size_t RowDim, size_t ColDim)(
    ref LUP!(T, RowDim, ColDim) lupResult)
{
    enum matrixDim = RowDim;
    FixedArrayMatrix!(T, RowDim, ColDim) result;

    foreach (j; 0 .. matrixDim)
    {
        foreach (i; 0 .. matrixDim)
        {
            result[i][j] = lupResult.permVec[i] == j ? 1.0 : 0.0;

            foreach (k; 0 .. i)
            {
                result[i][j] -= lupResult.LU[i][k] * result[k][j];
            }
        }

        foreach_reverse (i; 0 .. matrixDim)
        {
            foreach (k; i + 1 .. matrixDim)
            {
                result[i][j] -= lupResult.LU[i][k] * result[k][j];
            }
            result[i][j] /= lupResult.LU[i][i];
        }
    }
    return result;
}

double det(T = double, size_t RowDim, size_t ColDim)(ref LUP!(T, RowDim, ColDim) lupResult)
{
    immutable size_t matrixDim = lupResult.LU.length;
    double detResult = lupResult.LU[0][0];
    foreach (i; 1 .. matrixDim)
    {
        detResult *= lupResult.LU[i][i];
    }

    if (detResult == 0)
    {
        return detResult;
    }

    return (lupResult.permVec[matrixDim] - matrixDim) % 2 == 0 ? detResult : -detResult;
}

unittest
{
    import std.math.operations : isClose;
    import deltotum.core.maths.matrices.fixed_array_matrix : FixedArrayMatrix;

    auto m1 = FixedArrayMatrix!(double, 4, 4)([
        [2, 7, 6, 2],
        [9, 5, 1, 3],
        [4, 3, 8, 4],
        [5, 6, 7, 8],
    ]);
    auto m1Result = decompose!(double, 4, 4)(m1);
    import std.stdio;

    auto m1ResultLU = m1Result.LU;

    import std.algorithm.comparison : equal;

    assert(m1ResultLU[0] == [9, 5, 1, 3]);
    assert(equal!isClose(m1ResultLU[1][], [
                0.222222222, 5.888888888, 5.777777777, 1.333333333
            ]));
    assert(equal!isClose(m1ResultLU[2][], [
                0.444444444, 0.1320754717, 6.79245283, 2.4905660377
            ]));
    assert(equal!isClose(m1ResultLU[3][], [
                0.5555555555, 0.547169811, 0.483333333, 4.3999999999
            ]));

    auto m1Det = det(m1Result);
    assert(isClose(m1Det, -1584));

    auto invResult = invert(m1Result);
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

    //3x +2y + z =360
    //x + 6y +2z = 300
    //4x + y + 5z = 675
    auto m2 = FixedArrayMatrix!(double, 3, 3)([[3, 2, 1], [1, 6, 2], [4, 1, 5]]);
    auto m2lup = decompose(m2);
    auto m2result = solve(m2lup, [360, 300, 675]);
    assert(m2result[0] == 90);
    assert(m2result[1] == 15);
    assert(m2result[2] == 60);

    //3x - 2y = 6;
    //5x + 4y = 32;
    auto m3 = FixedArrayMatrix!(double, 2, 2)([[3, 2], [5, 4]]);
    auto m3lup = decompose(m3);
    auto m3result = solve(m3lup, [6, 32]);
    assert(isClose(m3result[0], -20));
    assert(isClose(m3result[1], 33));
}
