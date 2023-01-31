module deltotum.core.math.matrices.fixed_array_matrix;

/**
 * Authors: initkfs
 */
struct FixedArrayMatrix(T = double, size_t RowDimension = 1, size_t ColDimension = 1)
        if (RowDimension >= 1 && ColDimension >= 1)
{
    private
    {
        //TODO T.init for floating point
        T[ColDimension][RowDimension] matrix;
    }

    this(T initValue) pure @nogc nothrow @safe
    {
        fill(initValue);
    }

    this(const T[][] data) pure @safe
    {
        if (data.length != RowDimension)
        {
            import std.format : format;

            throw new Exception(
                format("Invalid row dimension. Expected %s but received %s", RowDimension, data
                    .length));
        }

        foreach (rowIndex, row; data)
        {
            if (row.length != ColDimension)
            {
                import std.format : format;

                throw new Exception(
                    format("Invalid column dimension with row index %s. Expected %s but received %s", rowIndex, ColDimension, row
                        .length));
            }
            foreach (columnIndex, columnValue; row)
            {
                matrix[rowIndex][columnIndex] = columnValue;
            }
        }
    }

    protected void eachRow(scope bool delegate(size_t rowIndex, scope const T[]) pure @safe onRow) const pure @safe
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

    FixedArrayMatrix!(T, RowDimension, ColDimension) add(
        FixedArrayMatrix!(T, RowDimension, ColDimension) other) const pure @safe
    {
        FixedArrayMatrix!(T, RowDimension, ColDimension) result;

        eachRow((rowIndex, row) {
            foreach (columnIndex, column; row)
            {
                result.value(rowIndex, columnIndex) = column + other.value(rowIndex, columnIndex);
            }
            return true;
        });
        return result;
    }

    FixedArrayMatrix!(T, RowDimension, ColDimension) sub(
        FixedArrayMatrix!(T, RowDimension, ColDimension) other) const pure @safe
    {
        FixedArrayMatrix!(T, RowDimension, ColDimension) result;

        eachRow((rowIndex, row) {
            foreach (columnIndex, column; row)
            {
                result.value(rowIndex, columnIndex) = column - other.value(rowIndex, columnIndex);
            }
            return true;
        });
        return result;
    }

    FixedArrayMatrix!(T, RowDimension, ColDimensionOther) multiply(T, size_t RowDimensionOther, size_t ColDimensionOther)(
        FixedArrayMatrix!(T, RowDimensionOther, ColDimensionOther) other) const pure @safe
            if (ColDimension == RowDimensionOther)
    {
        import std.traits;

        FixedArrayMatrix!(T, RowDimension, ColDimensionOther) result;

        //TODO Void arrays?
        static if (isFloatingPoint!T)
        {
            result.fill(0);
        }

        foreach (rowIndex; 0 .. rowDimension)
        {
            foreach (otherColIndex; 0 .. ColDimensionOther)
            {
                foreach (otherRowIndex; 0 .. RowDimensionOther)
                {
                    auto thisValue = matrix[rowIndex][otherRowIndex];
                    auto otherValue = other.value(otherRowIndex, otherColIndex);
                    result.value(rowIndex, otherColIndex) += thisValue * otherValue;
                }
            }
        }
        return result;
    }

    FixedArrayMatrix!(T, ColDimension, RowDimension) transpose() const pure @safe
    {
        FixedArrayMatrix!(T, ColDimension, RowDimension) result;

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
            result ~= matrix[RowDimension - 1 - rowIndex][rowIndex];
            return true;
        });
        return result;
    }

    void fill(T val) @nogc pure @safe
    {
        foreach (rowIndex; 0 .. RowDimension)
        {
            foreach (colIndex; 0 .. ColDimension)
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
        return RowDimension == ColDimension;
    }

    T[][] toArrayCopy() const pure @safe
    {
        T[][] result;
        eachRow((rowIndex, row) { result ~= row.dup; return true; });
        return result;
    }

    ref T value(size_t rowIndex, size_t columnIndex) @safe
    {
        if (rowIndex >= RowDimension)
        {
            import std.format : format;

            throw new Exception(format("Row index must be less than row dimension %s", RowDimension));
        }

        if (columnIndex >= ColDimension)
        {
            import std.format : format;

            throw new Exception(format("Column index must be less than column dimension %s", ColDimension));
        }

        return matrix[rowIndex][columnIndex];
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
        return RowDimension;
    }

    size_t columnDimension() const @nogc nothrow pure @safe
    {
        return ColDimension;
    }

    unittest
    {
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
    }
}
