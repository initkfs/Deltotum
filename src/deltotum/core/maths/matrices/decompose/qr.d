module deltotum.core.maths.matrices.decompose.qr;

import deltotum.core.maths.matrices.dense_matrix : DenseMatrix;
import Math = deltotum.core.maths.math;

/**
 * Authors: initkfs
 * QR Decomposition, computed by Householder reflections.
 * Part of the calculations ported from the JAMA library, Public Domain License: https://math.nist.gov/javanumerics/jama
 * 
 */
struct QR(T = double, size_t RowDim, size_t ColDim)
        if (RowDim > 0 && ColDim > 0 && RowDim >= ColDim)
{
    T[ColDim][RowDim] QR;
    // diagonal of R.
    double[ColDim] Rdiag;

    DenseMatrix!(T, ColDim, ColDim) factorR()
    {
        typeof(return) result;

        if (QR.length == 0 || Rdiag.length == 0)
        {
            return result;
        }

        foreach (i; 0 .. ColDim)
        {
            foreach (j; 0 .. ColDim)
            {
                if (i < j)
                {
                    result[i][j] = QR[i][j];
                }
                else if (i == j)
                {
                    result[i][j] = Rdiag[i];
                }
                else
                {
                    result[i][j] = 0;
                }
            }
        }
        return result;
    }

    DenseMatrix!(T, RowDim, ColDim) factorQ()
    {
        typeof(return) result;

        import std.math.operations : isClose;

        foreach_reverse (k; 0 .. ColDim)
        {
            foreach (i; 0 .. RowDim)
            {
                result[i][k] = 0;
            }
            result[k][k] = 1.0;
            foreach (j; k .. ColDim)
            {
                if (QR[k][k] != 0.0)
                {
                    double s = 0;
                    foreach (i; k .. RowDim)
                    {
                        s += QR[i][k] * result[i][j];
                    }
                    s = -s / QR[k][k];
                    foreach (i; k .. RowDim)
                    {
                        result[i][j] += s * QR[i][k];
                    }
                }
            }
        }
        return result;
    }

    bool isFullRank()
    {
        foreach (j; 0 .. ColDim)
        {
            if (Rdiag[j] == 0)
            {
                return false;
            }

        }
        return true;
    }

    DenseMatrix!(T, RowDim, ColDim) householder()
    {
        typeof(return) result;
        foreach (i; 0 .. RowDim)
        {
            foreach (j; 0 .. ColDim)
            {
                if (i >= j)
                {
                    result[i][j] = QR[i][j];
                }
                else
                {
                    result[i][j] = 0.0;
                }
            }
        }
        return result;
    }
}

/** 
 * https://en.wikipedia.org/wiki/QR_decomposition
 */
QR!(T, RowDim, ColDim) decompose(T = double, size_t RowDim, size_t ColDim)(
    ref DenseMatrix!(T, RowDim, ColDim) matrix)
        if (RowDim > 0 && ColDim > 0 && RowDim >= ColDim)
{
    typeof(return) result;

    foreach (i, ref row; result.QR)
    {
        row[] = matrix[i];
    }

    result.Rdiag[] = 0;

    import std.math.operations : isClose;

    foreach (k; 0 .. ColDim)
    {
        // Compute 2-norm of k-th column without under/overflow.
        double nrm = 0;
        foreach (i; k .. RowDim)
        {
            nrm = Math.hypot(nrm, result.QR[i][k]);
        }

        if (nrm != 0)
        {
            // Form k-th Householder vector.
            if (result.QR[k][k] < 0)
            {
                nrm = -nrm;
            }
            foreach (i; k .. RowDim)
            {
                result.QR[i][k] /= nrm;
            }
            result.QR[k][k] += 1.0;

            // Apply transformation to remaining columns.
            foreach (j; (k + 1) .. ColDim)
            {
                double s = 0.0;
                foreach (i; k .. RowDim)
                {
                    s += result.QR[i][k] * result.QR[i][j];
                }
                s = -s / result.QR[k][k];
                foreach (i; k .. RowDim)
                {
                    result.QR[i][j] += s * result.QR[i][k];
                }
            }
        }
        result.Rdiag[k] = -nrm;
    }

    return result;
}

/** 
 * Least squares solution of A*X = B
 * //TODO replace double[] with matrix
 */
auto solve(T = double, size_t RowDim, size_t ColDim)(
    ref QR!(T, RowDim, ColDim) qr, double[] B)
        if (RowDim > 1 && ColDim > 1 && RowDim == ColDim)
{
    if (!qr.isFullRank())
    {
        throw new Exception("Matrix is rank deficient.");
    }

    //TODO rewrite without creating a large matrix
    scope double[][] temp = new double[][](B.length, B.length);
    foreach (i, ref row; temp)
    {
        row[] = B[i];
    }

    size_t nx = B.length;

    // Compute Y = transpose(Q)*B
    foreach (k; 0 .. ColDim)
    {
        foreach (j; 0 .. nx)
        {
            double s = 0.0;
            foreach (i; k .. RowDim)
            {
                s += qr.QR[i][k] * temp[i][j];
            }
            s = -s / qr.QR[k][k];
            foreach (i; k .. RowDim)
            {
                temp[i][j] += s * qr.QR[i][k];
            }
        }
    }
    // Solve R*X = Y;
    foreach_reverse (k; 0 .. ColDim)
    {
        foreach (j; 0 .. nx)
        {
            temp[k][j] /= qr.Rdiag[k];
        }
        foreach (i; 0 .. k)
        {
            foreach (j; 0 .. nx)
            {
                temp[i][j] -= temp[k][j] * qr.QR[i][k];
            }
        }
    }

    double[] result;
    foreach (i, ref row; temp)
    {
        result ~= row[0];
        continue;
    }

    return result;
}

unittest
{
    import std.math.operations : isClose;
    import std.algorithm.comparison : equal;
    import deltotum.core.maths.matrices.dense_matrix : DenseMatrix;

    auto m1 = DenseMatrix!(double, 4, 3)([
        [2, 7, 6],
        [9, 5, 1],
        [4, 3, 8],
        [4, 5, 2]
    ]);
    auto m1Result = decompose!(double, 4, 3)(m1);

    auto m1QFactor = m1Result.factorQ;
    assert(equal!isClose(m1QFactor[0], [
                -0.1849000654, 0.8923853290, -0.0074982814
            ]));
    assert(equal!isClose(m1QFactor[1], [
                -0.8320502943, -0.3278150188, 0.2882984081
            ]));
    assert(equal!isClose(m1QFactor[2], [
                -0.3698001308, -0.0182119455, -0.9178036585
            ]));
    assert(equal!isClose(m1QFactor[3], [
                -0.3698001308, 0.3096030733, 0.2728813809
            ]));

    auto m1RFactor = m1Result.factorR;
    assert(equal!isClose(m1RFactor.toArrayCopy, [
                [-10.8166538264, -8.4129529761, -5.6394519950],
                [0, 6.1010017392, 5.5000075381],
                [0, 0, -6.5533577865]
            ]));

    //3x +2y + z =360
    //x + 6y +2z = 300
    //4x + y + 5z = 675
    auto m2 = DenseMatrix!(double, 3, 3)([[3, 2, 1], [1, 6, 2], [4, 1, 5]]);
    auto m2qr = decompose(m2);
    auto m2result = solve(m2qr, [360, 300, 675]);
    assert(isClose(m2result[0], 90));
    assert(isClose(m2result[1], 15));
    assert(isClose(m2result[2], 60));
}
