module api.math.matrices.decompose.lup;

import api.math.versions;

version (EnableMathCustom)
{
    public import api.math.matrices.decompose.jama.lup_jama;
}
else
{
    public import api.math.matrices.decompose.jama.lup_jama;
}

unittest
{
    import std.math.operations : isClose;
    import api.math.matrices.dense_matrix : DenseMatrix;

    auto m1 = DenseMatrix!(float, 4, 4)([
        [2, 7, 6, 2],
        [9, 5, 1, 3],
        [4, 3, 8, 4],
        [5, 6, 7, 8],
    ]);
    auto m1Result = decompose!(float, 4, 4)(m1);

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
    auto m2 = DenseMatrix!(float, 3, 3)([[3, 2, 1], [1, 6, 2], [4, 1, 5]]);
    auto m2lup = decompose(m2);
    auto m2result = solve(m2lup, [360, 300, 675]);
    assert(m2result[0] == 90);
    assert(m2result[1] == 15);
    assert(m2result[2] == 60);

    //3x - 2y = 6;
    //5x + 4y = 32;
    auto m3 = DenseMatrix!(float, 2, 2)([[3, 2], [5, 4]]);
    auto m3lup = decompose(m3);
    auto m3result = solve(m3lup, [6, 32]);
    assert(isClose(m3result[0], -20));
    assert(isClose(m3result[1], 33));
}
