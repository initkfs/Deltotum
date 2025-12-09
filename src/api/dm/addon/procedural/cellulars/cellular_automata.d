module api.dm.addon.procedural.cellulars.cellular_automata;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.math.geom2.rect2 : Rect2d;
import api.dm.kit.graphics.colors.rgba : RGBA;

enum NeighborhoodType : uint
{
    Moore = 8,
    VonNeumann = 4
}

struct CellConfig
{
    NeighborhoodType neighborhood = NeighborhoodType.Moore;
    float initialDensity = 0.3;
    size_t width = 200;
    size_t height = 200;
    size_t cellSize = 3;
    RuleType rule = RuleType.Rule30;
    bool wrapAround;
}

enum RuleType
{
    GameOfLife,
    Rule30,
    Rule110
}

class CellularAutomaton : Sprite2d
{

    CellConfig config;

    protected
    {
        bool[][] _currentState;
        bool[][] _nextState;

        size_t _cols;
        size_t _rows;
    }

    Rect2d[] cellDrawBuffer;

    this(CellConfig config = CellConfig.init)
    {
        this.config = config;

        _cols = config.width / config.cellSize;
        _rows = config.height / config.cellSize;

        _currentState = new bool[][](_rows, _cols);
        _nextState = new bool[][](_rows, _cols);

        cellDrawBuffer = new Rect2d[_rows * _cols];
        //initializeState;

        resize(config.width, config.height);
    }

    override void drawContent()
    {
        super.drawContent;
        render;
    }

    override void update(float dt)
    {
        super.update(dt);
        updateState;
    }

    void initializeState()
    {
        initializeRandom;
    }

    private void initializeRandom()
    {
        import std.random : uniform;

        foreach (i; 0 .. _currentState.length)
        {
            foreach (j; 0 .. _currentState[i].length)
            {
                _currentState[i][j] = uniform(0.0, 1.0) < config.initialDensity;
            }
        }
    }

    void onCurrentState(scope bool delegate(size_t ri, size_t ci, bool ptr) onCellValueIsContinue)
    {
        foreach (ri, row; _currentState)
        {
            foreach (ci, col; row)
            {
                if (!onCellValueIsContinue(ri, ci, col))
                {
                    return;
                }
            }
        }
    }

    bool* cellPtr(size_t row, size_t col)
    {
        if (config.wrapAround)
        {
            auto rows = _currentState.length;
            auto cols = _rows > 0 ? _currentState[0].length : 0;
            return &(_currentState[(_rows + row) % rows][(_cols + col) % cols]);
        }

        if (row >= 0 && row < _currentState.length &&
            (col >= 0 && _currentState.length > 0 && col < _currentState[0].length))
        {
            return &(_currentState[row][col]);
        }

        return null;
    }

    bool cell(size_t row, size_t col)
    {
        if (auto ptr = cellPtr(row, col))
        {
            return *ptr;
        }

        return false;
    }

    void cell(size_t row, size_t col, bool value, bool isThrowOnInvalidCell = false)
    {
        if (auto ptr = cellPtr(row, col))
        {
            *ptr = value;
        }

        if (isThrowOnInvalidCell)
        {
            import std.format : format;

            throw new Exception(format("Invalid cell, row:%s, col:%s", row, col));
        }
    }

    private size_t countNeighbors(size_t row, size_t col)
    {
        size_t count = 0;

        switch (config.neighborhood)
        {
            case NeighborhoodType.Moore:
                count = countMooreNeighbors(row, col);
                break;

            case NeighborhoodType.VonNeumann:
                count = countVonNeumannNeighbors(row, col);
                break;
            default:
                break;
        }

        return count;
    }

    private ptrdiff_t wrapAround(ptrdiff_t index, ptrdiff_t size)
    {
        return ((index % size) + size) % size;
    }

    size_t countMooreNeighbors(size_t row, size_t col, size_t dim = 1)
    {
        assert(dim > 0);

        size_t count = 0;
        size_t rows = _currentState.length;
        size_t cols = _currentState[0].length;

        ptrdiff_t startRow = row - dim;
        ptrdiff_t startCol = col - dim;

        const size_t size = dim * 2 + 1;

        foreach (ri; 0 .. size)
        {
            ptrdiff_t newRowIndex = startRow + ri;
            if (newRowIndex < 0)
            {
                if (config.wrapAround)
                {
                    assert(rows > 0);
                    newRowIndex = wrapAround(newRowIndex, rows);
                }
                else
                {
                    continue;
                }
            }

            if (newRowIndex >= rows)
            {
                if (config.wrapAround)
                {
                    newRowIndex = newRowIndex % rows;
                }
                else
                {
                    continue;
                }
            }

            assert(newRowIndex >= 0 && newRowIndex < rows);

            foreach (ci; 0 .. size)
            {
                ptrdiff_t newColIndex = startCol + ci;
                if (newColIndex < 0)
                {
                    if (config.wrapAround)
                    {
                        assert(cols > 0);
                        newColIndex = wrapAround(newColIndex, cols);
                    }
                    else
                    {
                        continue;
                    }
                }

                if (newColIndex >= cols)
                {
                    if (config.wrapAround)
                    {
                        newColIndex = newColIndex % cols;
                    }
                    else
                    {
                        continue;
                    }
                }

                assert(newColIndex >= 0 && newColIndex < cols);

                if (newRowIndex == row && newColIndex == col)
                {
                    continue;
                }

                if (_currentState[newRowIndex][newColIndex])
                {
                    count++;
                }

            }
        }

        return count;
    }

    private size_t countVonNeumannNeighbors(size_t row, size_t col)
    {
        size_t count = 0;
        size_t rows = _currentState.length;
        size_t cols = _currentState[0].length;

        static immutable int[][] vonNeumannOffsets = [
            [-1, 0], [1, 0], [0, -1], [0, 1]
        ];

        foreach (offset; vonNeumannOffsets)
        {
            size_t neighborRow = row + offset[0];
            size_t neighborCol = col + offset[1];

            if (config.wrapAround)
            {
                neighborRow %= rows;
                neighborCol %= cols;
            }

            if (neighborRow < rows && neighborCol < cols &&
                _currentState[neighborRow][neighborCol])
            {
                count++;
            }
        }

        return count;
    }

    private bool applyGameOfLife(size_t row, size_t col)
    {
        size_t neighbors = countNeighbors(row, col);
        bool current = cell(row, col);

        if (current)
        {
            return neighbors == 2 || neighbors == 3;
        }
        else
        {
            return neighbors == 3;
        }
    }

    bool applyRules(size_t row, size_t col)
    {
        return false;
    }

    size_t startRow() => 0;

    size_t count;

    void updateState()
    {
        // if (count <= 50)
        // {
        //     count++;
        //     return;
        // }

        // count = 0;

        size_t firstRow = startRow;

        size_t bufferPos;

        cellDrawBuffer[] = Rect2d.init;

        if (firstRow != 0)
        {
            if (firstRow == 1)
            {
                _nextState[0][] = _currentState[0][];
            }
            else
            {
                foreach (ri; 0 .. firstRow)
                {
                    _nextState[ri][] = _currentState[ri][];
                }
            }
        }

        foreach (ri; firstRow .. _currentState.length)
        {
            foreach (ci; 0 .. _currentState[ri].length)
            {
                bool isRule = applyRules(ri, ci);
                if (isRule)
                {
                    _nextState[ri][ci] = true;
                    cellDrawBuffer[bufferPos] = Rect2d(x + ci * config.cellSize, y + (
                            ri * config.cellSize + (firstRow * config.cellSize)), config
                            .cellSize, config
                            .cellSize);
                    bufferPos++;
                }
                else
                {
                    _nextState[ri][ci] = false;
                }
            }
        }

        auto temp = _currentState;
        _currentState = _nextState;
        _nextState = temp;
    }

    private void render()
    {
        graphic.fillRects(cellDrawBuffer, RGBA.yellowgreen);
    }

    void reset()
    {
        foreach (ref row; _currentState)
        {
            row[] = false;
        }
        foreach (ref row; _nextState)
        {
            row[] = false;
        }
    }

    inout(bool[][]) currentState() inout => _currentState;
    size_t rows() => _rows;
    size_t cols() => _cols;

    void printState()
    {
        import std.stdio : writeln;

        foreach (ref row; _currentState)
        {
            writeln(row);
        }
    }
}

unittest
{
    CellConfig config;
    config.width = 6;
    config.height = 4;
    config.cellSize = 1;

    auto cellurar = new CellularAutomaton(config);
    cellurar.cell(1, 2, true);

    import std.format : format;

    cellurar.onCurrentState((ri, ci, col) {
        if (ri == 1 && ci == 2)
        {
            assert(col, format("%s:%s", ri, ci));
            return true;
        }

        assert(!col, format("%s:%s", ri, ci));
        return true;
    });
    assert(cellurar.cell(1, 2));
    cellurar.config.wrapAround = true;
    assert(cellurar.cell(5, 8));
    assert(!cellurar.cell(5, 7));
    assert(!cellurar.cell(5, 5));
    assert(!cellurar.cell(4, 8));
    assert(!cellurar.cell(3, 8));
    cellurar.config.wrapAround = false;
}

unittest
{
    CellConfig config;
    config.width = 5;
    config.height = 5;
    config.cellSize = 1;
    config.neighborhood = NeighborhoodType.Moore;
    auto cellular = new CellularAutomaton(
        config);
    cellular.cell(0, 0, true);
    cellular.cell(2, 2, true);

    assert(cellular.countMooreNeighbors(0, 0) == 0);
    assert(
        cellular.countMooreNeighbors(2, 2) == 0);
    assert(
        cellular.countMooreNeighbors(1, 1) == 2);
    assert(
        cellular.countMooreNeighbors(1, 0) == 1);
    assert(
        cellular.countMooreNeighbors(2, 1) == 1);
}
