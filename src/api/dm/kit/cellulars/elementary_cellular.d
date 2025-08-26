module api.dm.kit.cellulars.elementary_cellular;

import api.dm.kit.cellulars.cellular_automata;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.math.geom2.rect2 : Rect2d;
import api.dm.kit.graphics.colors.rgba : RGBA;

class ElementaryCellular : CellularAutomaton
{

    protected
    {
        bool[8] _rulePattern;
    }

    this(ubyte defaultRule = 30, CellConfig config = CellConfig.init)
    {
        super(config);
        _rulePattern = toWolfram(defaultRule);
        initializeState;
    }

    //override size_t startRow() => 1;

    final bool[8] toWolfram(ubyte num)
    {
        bool[8] pattern;
        foreach (i; 0 .. 8)
        {
            pattern[i] = (num & (1 << (7 - i))) != 0;
        }

        return pattern;
    }

    override size_t startRow() => 1;

    override void initializeState()
    {
        foreach (i; 0 .. _currentState.length)
        {
            foreach (j; 0 .. _currentState[i].length)
            {
                _currentState[i][j] = false;
            }
        }

        //1 cell
        if (_currentState.length > 0 && _currentState[0].length > 0)
        {
            auto center = _currentState[0].length / 2;
            _currentState[0][center] = true;
        }
    }

    override bool applyRules(size_t row, size_t col)
    {
        const size_t lastRowIndex = rows == 0 ? 0 : rows - 1;
        const size_t lastColIndex = cols == 0 ? 0 : cols - 1;

        if (row == 0 || row > lastRowIndex)
        {
            return false;
        }

        if (col == 0 || col >= lastColIndex)
        {
            return false;
        }

        const prevRowIdx = row - 1;
        const leftColIdx = col - 1;
        const rightColIdx = col + 1;

        bool left = cell(prevRowIdx, leftColIdx);
        bool center = cell(prevRowIdx, col);
        bool right = cell(prevRowIdx, rightColIdx);

        ubyte index = patternIndex(left, center, right);

        return _rulePattern[index];
    }

    ubyte patternIndex(bool left, bool center, bool right)
    {
        ubyte index = 0;

        // 111(7), 110(6), 101(5), 100(4), 011(3), 010(2), 001(1), 000(0)
        if (left)
            index |= 0b100;
        if (center)
            index |= 0b010;
        if (right)
            index |= 0b001;

        return cast(ubyte)(7 - index);
    }

    inout(bool[8]) rulePattern() inout => _rulePattern;

    void rulePattern(ubyte num)
    {
        _rulePattern = toWolfram(num);
    }

}

unittest
{
    CellConfig config;
    config.width = 6;
    config.height = 4;
    config.cellSize = 1;

    auto cellurar = new ElementaryCellular(30, config);
    assert(cellurar.rulePattern == [
        false, false, false, true, true, true, true, false
    ]);
    cellurar.rulePattern = 110;
    assert(cellurar.rulePattern == [
        false, true, true, false, true, true, true, false
    ]);

    //111(0), 110(1), 101(2), 100(3), 011(4), 010(5), 001(6), 000(7)
    assert(cellurar.patternIndex(true, true, true) == 0);
    assert(cellurar.patternIndex(true, true, false) == 1);
    assert(cellurar.patternIndex(true, false, true) == 2);
    assert(cellurar.patternIndex(true, false, false) == 3);
    assert(cellurar.patternIndex(false, true, true) == 4);
    assert(cellurar.patternIndex(false, true, false) == 5);
    assert(cellurar.patternIndex(false, false, true) == 6);
    assert(cellurar.patternIndex(false, false, false) == 7);

    config = CellConfig.init;
    config.width = 5;
    config.height = 5;
    config.cellSize = 1;
    cellurar = new ElementaryCellular(30, config);

    assert(cellurar.currentState == [
        [false, false, true, false, false],
        [false, false, false, false, false],
        [false, false, false, false, false],
        [false, false, false, false, false],
        [false, false, false, false, false]
    ]);

    cellurar.updateState;

    assert(cellurar.currentState == [
        [false, false, true, false, false],
        [false, true, true, true, false],
        [false, false, false, false, false],
        [false, false, false, false, false],
        [false, false, false, false, false]
    ]);

    cellurar.updateState;

    assert(cellurar.currentState == [
        [false, false, true, false, false],
        [false, true, true, true, false],
        [false, true, false, false, false],
        [false, false, false, false, false],
        [false, false, false, false, false]
    ]);

    cellurar.updateState;

    assert(cellurar.currentState == [
        [false, false, true, false, false],
        [false, true, true, true, false],
        [false, true, false, false, false],
        [false, true, true, false, false],
        [false, false, false, false, false]
    ]);

    cellurar.updateState;

    assert(cellurar.currentState == [
        [false, false, true, false, false],
        [false, true, true, true, false],
        [false, true, false, false, false],
        [false, true, true, false, false],
        [false, true, false, true, false]
    ]);

}
