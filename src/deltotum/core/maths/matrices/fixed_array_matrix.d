module deltotum.core.maths.matrices.fixed_array_matrix;

/**
 * Authors: initkfs
 */
struct FixedArrayMatrix(T = double, size_t RowDim = 1, size_t ColDim = 1)
        if (RowDim >= 1 && ColDim >= 1)
{
    //TODO make private
    //private
    //{
        //TODO T.init for floating point
        T[ColDim][RowDim] matrix;
    //}

    this(T initValue) pure @nogc nothrow @safe
    {
        fill(initValue);
    }

    this(const T[][] data) pure @safe
    {
        if (data.length != RowDim)
        {
            import std.format : format;

            throw new Exception(
                format("Invalid row dimension. Expected %s but received %s", RowDim, data
                    .length));
        }

        foreach (rowIndex, row; data)
        {
            if (row.length != ColDim)
            {
                import std.format : format;

                throw new Exception(
                    format("Invalid column dimension with row index %s. Expected %s but received %s", rowIndex, ColDim, row
                        .length));
            }
            foreach (columnIndex, columnValue; row)
            {
                matrix[rowIndex][columnIndex] = columnValue;
            }
        }
    }

    void eachRow(scope bool delegate(size_t rowIndex, scope const T[]) pure @safe onRow) const pure @safe
    {
        foreach (size_t rowIndex, const ref row; matrix)
        {
            const T[] rowSlice = row;
            immutable isContinue = onRow(rowIndex, rowSlice);
            if (!isContinue)
            {
                break;
            }
        }
    }

    void eachCol(scope bool delegate(size_t rowIndex, size_t colIndex, T value) pure @safe onCol) const pure @safe
    {
        //immutable -> const(col)
        foreach (size_t rowIndex, ref row; matrix)
        {
            foreach (colIndex, ref col; row)
            {
                immutable isContinue = onCol(rowIndex, colIndex, col);
                if (!isContinue)
                {
                    return;
                }
            }
        }
    }

    FixedArrayMatrix!(T, RowDim, ColDim) add(
        FixedArrayMatrix!(T, RowDim, ColDim) other) const pure @safe
    {
        FixedArrayMatrix!(T, RowDim, ColDim) result;

        eachRow((rowIndex, row) {
            foreach (columnIndex, column; row)
            {
                result.value(rowIndex, columnIndex) = column + other.value(rowIndex, columnIndex);
            }
            return true;
        });
        return result;
    }

    FixedArrayMatrix!(T, RowDim, ColDim) sub(
        FixedArrayMatrix!(T, RowDim, ColDim) other) const pure @safe
    {
        FixedArrayMatrix!(T, RowDim, ColDim) result;

        eachRow((rowIndex, row) {
            foreach (columnIndex, column; row)
            {
                result.value(rowIndex, columnIndex) = column - other.value(rowIndex, columnIndex);
            }
            return true;
        });
        return result;
    }

    FixedArrayMatrix!(T, RowDim, ColDimOther) multiply(T, size_t RowDimOther, size_t ColDimOther)(
        FixedArrayMatrix!(T, RowDimOther, ColDimOther) other) const pure @safe
            if (ColDim == RowDimOther)
    {
        import std.traits;

        FixedArrayMatrix!(T, RowDim, ColDimOther) result;

        //TODO Void arrays?
        static if (isFloatingPoint!T)
        {
            result.fill(0);
        }

        foreach (rowIndex; 0 .. rowDimension)
        {
            foreach (otherColIndex; 0 .. ColDimOther)
            {
                foreach (otherRowIndex; 0 .. RowDimOther)
                {
                    auto thisValue = matrix[rowIndex][otherRowIndex];
                    auto otherValue = other.value(otherRowIndex, otherColIndex);
                    result.value(rowIndex, otherColIndex) += thisValue * otherValue;
                }
            }
        }
        return result;
    }

    FixedArrayMatrix!(T, ColDim, RowDim) transpose() const pure @safe
    {
        FixedArrayMatrix!(T, ColDim, RowDim) result;

        eachRow((rowIndex, row) {
            foreach (columnIndex, column; row)
            {
                result.value(columnIndex, rowIndex) = column;
            }
            return true;
        });
        return result;
    }

    T[] mainDiagonal() const pure @safe
    {
        T[] result;
        eachRow((rowIndex, row) {
            result ~= matrix[rowIndex][rowIndex];
            return true;
        });
        return result;
    }

    T[] sideDiagonal() const pure @safe
    {
        T[] result;
        eachRow((rowIndex, row) {
            result ~= matrix[RowDim - 1 - rowIndex][rowIndex];
            return true;
        });
        return result;
    }

    void fill(T val) @nogc pure @safe
    {
        foreach (rowIndex; 0 .. RowDim)
        {
            foreach (colIndex; 0 .. ColDim)
            {
                matrix[rowIndex][colIndex] = val;
            }
        }
    }

    void fillInit() @nogc pure @safe
    {
        import std.traits : isFloatingPoint;

        static if (isFloatingPoint!T)
        {
            enum initValue = 0;
        }
        else
        {
            enum initValue = T.init;
        }
        fill(initValue);
    }

    bool isSquare() const @nogc nothrow pure @safe
    {
        return RowDim == ColDim;
    }

    bool isEmpty() const @nogc nothrow pure @safe
    {
        return RowDim == 0;
    }

    auto minor(size_t targetRow, size_t targetCol) const pure @safe
    {
        static if (ColDim == RowDim && RowDim >= 2)
        {
            FixedArrayMatrix!(T, ColDim - 1, RowDim - 1) result;
            if (!isSquare || rowDimension < 2 || columnDimension < 2)
            {
                return result;
            }

            if (targetRow >= rowDimension)
            {
                import std.format : format;

                throw new Exception(format("Row max index is %s, but received %s", rowDimension - 1, targetRow));
            }

            if (targetCol >= columnDimension)
            {
                import std.format : format;

                throw new Exception(format("Column max index is %s, but received %s", columnDimension - 1, targetCol));
            }

            immutable size_t minorSize = rowDimension - 1;

            foreach (rowIndex; 0 .. minorSize)
                foreach (colIndex; 0 .. minorSize)
                {
                    if (rowIndex < targetRow && colIndex < targetCol)
                    {
                        result[rowIndex][colIndex] = matrix[rowIndex][colIndex];
                    }
                    else if (rowIndex >= targetRow && colIndex < targetCol)
                    {
                        result[rowIndex][colIndex] = matrix[rowIndex + 1][colIndex];
                    }
                    else if (rowIndex < targetRow && colIndex >= targetCol)
                    {
                        result[rowIndex][colIndex] = matrix[rowIndex][colIndex + 1];
                    }
                    else
                    {
                        result[rowIndex][colIndex] = matrix[rowIndex + 1][colIndex + 1];
                    }
                }

            return result;
        }
        else
        {
            FixedArrayMatrix!(T, ColDim, RowDim) result;
            return result;
        }
    }

    double det() const pure @safe
    {
        if (!isSquare)
        {
            return T.init;
        }

        if (rowDimension == 1)
        {
            return matrix[0][0];
        }

        byte sign = 1;
        double result = 0;
        foreach (i; 0 .. rowDimension)
        {
            result += sign * matrix[0][i] * minor(0, i).det;
            sign *= -1;
        }

        return result;
    }

    double permanent() const pure @safe
    {
        if (rowDimension == 1)
        {
            return matrix[0][0];
        }

        double sum = 0;
        foreach (i; 0 .. rowDimension)
        {
            sum += matrix[0][i] * minor(0, i).permanent;
        }
        return sum;
    }

    T[][] toArrayCopy() const pure @safe
    {
        T[][] result;
        eachRow((rowIndex, row) { result ~= row.dup; return true; });
        return result;
    }

    ref T value(size_t rowIndex, size_t columnIndex) @safe
    {
        if (rowIndex >= RowDim)
        {
            import std.format : format;

            throw new Exception(format("Row index must be less than row dimension %s", RowDim));
        }

        if (columnIndex >= ColDim)
        {
            import std.format : format;

            throw new Exception(format("Column index must be less than column dimension %s", ColDim));
        }

        return matrix[rowIndex][columnIndex];
    }

    T[] opIndex(size_t rowIndex)
    {
        if (rowIndex >= RowDim)
        {
            import std.format : format;

            throw new Exception(format("Row index must be less than row dimension %s", RowDim));
        }
        return matrix[rowIndex];
    }

    ref T opIndex(size_t row, size_t col)
    {
        return value(row, col);
    }

    string toString() const
    {
        import std.array : appender, join;
        import std.algorithm.iteration : map;
        import std.format : format;
        import std.conv : to;
        import std.traits : Unqual;

        auto buffer = appender!string;
        enum separator = '\n';
        buffer.put(format("%sx%s %s%s", rowDimension, columnDimension, Unqual!(typeof(this)).stringof, separator));
        eachRow((rowIndex, row) {
            buffer.put(row.map!(x => to!string(x)).join(" "));
            buffer.put(separator);
            return true;
        });
        return buffer.data;
    }

    size_t rowDimension() const @nogc nothrow pure @safe
    {
        return RowDim;
    }

    size_t columnDimension() const @nogc nothrow pure @safe
    {
        return ColDim;
    }
}

unittest
{
    import std.math.operations : isClose;

    immutable m0 = FixedArrayMatrix!(double, 1, 1)([[0]]);
    assert(m0.transpose.toArrayCopy == [[0]]);
    assert(m0.mainDiagonal == [0]);
    assert(m0.sideDiagonal == [0]);
    assert(m0.add(m0).toArrayCopy == [[0]]);
    assert(m0.multiply(m0).toArrayCopy == [[0]]);

    double[][] m1Data = [
        [1, 2, 3],
        [4, 5, 6]
    ];
    immutable m1 = FixedArrayMatrix!(double, 2, 3)(m1Data);

    assert(m1.rowDimension == 2);
    assert(m1.columnDimension == 3);

    auto transM1 = m1.transpose;
    assert(transM1.toArrayCopy == [[1, 4], [2, 5], [3, 6]]);

    auto m1Add = m1.add(m1);
    assert(m1Add.toArrayCopy == [[2, 4, 6], [8, 10, 12]]);

    auto m1Sub = m1.sub(m1);
    assert(m1Sub.toArrayCopy == [[0, 0, 0], [0, 0, 0]]);

    immutable m2 = FixedArrayMatrix!(double, 3, 3)([
        [1, 2, 3], [4, 5, 6], [6, 7, 8]
    ]);

    auto m1m2Multiply = m1.multiply(m2);
    assert(m1m2Multiply.toArrayCopy == [[27, 33, 39], [60, 75, 90]]);

    immutable m3 = FixedArrayMatrix!(double, 3, 4)([
        [1, 2, 3, 4],
        [5, 6, 7, 8],
        [9, 10, 11, 12]
    ]);

    assert(m3.mainDiagonal == [1, 6, 11]);
    assert(m3.sideDiagonal == [9, 6, 3]);

    immutable m4 = FixedArrayMatrix!(double, 3, 3)([
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9]
    ]);

    assert(m4.mainDiagonal == [1, 5, 9]);
    assert(m4.sideDiagonal == [7, 5, 3]);

    immutable mat22 = FixedArrayMatrix!(double, 2, 2)([
            [1, 2],
            [3, 4],
        ]);

    auto minor00Mat22 = mat22.minor(0, 0);
    assert(minor00Mat22.toArrayCopy == [[4]]);
    auto minor11Mat22 = mat22.minor(1, 1);
    assert(minor11Mat22.toArrayCopy == [[1]]);

    immutable mmin = FixedArrayMatrix!(double, 4, 4)([
        [1, 2, 3, 4],
        [5, 6, 7, 8],
        [9, 10, 11, 12],
        [13, 14, 15, 16]
    ]);

    auto minor00 = mmin.minor(0, 0);
    assert(minor00[0] == [6, 7, 8]);
    assert(minor00[1] == [10, 11, 12]);
    assert(minor00[2] == [14, 15, 16]);

    auto minor22 = mmin.minor(2, 2);
    assert(minor22[0] == [1, 2, 4]);
    assert(minor22[1] == [5, 6, 8]);
    assert(minor22[2] == [13, 14, 16]);

    auto minor33 = mmin.minor(3, 3);
    assert(minor33[0] == [1, 2, 3]);
    assert(minor33[1] == [5, 6, 7]);
    assert(minor33[2] == [9, 10, 11]);

    auto dd1 = FixedArrayMatrix!(double, 2, 2)([
            [1, 2],
            [3, 4]
        ]);
    auto dd1Det = dd1.det;
    assert(dd1Det == -2);

    auto dd2 = FixedArrayMatrix!(double, 4, 4)([
        [11, 21, 32, 4],
        [15, 56, 32, 12],
        [23, 22, 11, 10],
        [11, 76, 32, 56]
    ]);
    auto dd2Det = dd2.det;
    assert(isClose(dd2Det, -811036));
}
