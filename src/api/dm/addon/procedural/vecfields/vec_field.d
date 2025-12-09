module api.dm.addon.procedural.vecfields.vec_field;

import api.math.geom2.rect2 : Rect2f;
import api.math.geom2.vec2 : Vec2f;

import Math = api.math;

struct FieldVec
{
    float polarAngleRad = 0;
    float length = 0;

    Vec2f toVec2() => Vec2f.fromPolarRad(polarAngleRad, length);
}

/**
 * Authors: initkfs
 */
class VecField
{
    Rect2f gridBounds;
    FieldVec[][] grid;

    size_t steps = 20;
    float resolution = 40;

    protected
    {
        size_t _colCount;
        size_t _rowCount;

        float _width = 0;
        float _height = 0;

        float _stepLength = 0;
    }

    this(float fieldWidth = 100, float fieldHeight = 100)
    {
        _width = fieldWidth;
        _height = fieldHeight;
    }

    void createGrid(float startX, float startY)
    {
        auto leftX = _width * -0.5;
        auto rightX = _width * 1.5;
        auto topY = _height * -0.5;
        auto bottomY = _height * 1.5;
        //resolution = _width * 0.05;
        
        _colCount = cast(size_t)((rightX - leftX) / resolution);
        _rowCount = cast(size_t)((bottomY - topY) / resolution);

        gridBounds = Rect2f(startX + leftX, startY + topY, rightX - leftX, bottomY - topY);

        //0.1%-0.5% width
        if (_stepLength == 0)
        {
            _stepLength = _width * 0.15;
        }

        grid = new FieldVec[][](_colCount, _rowCount);
    }

    void rotateGrid()
    {
        foreach (r, ref row; grid)
        {
            foreach (c, ref col; row)
            {
                const angle = (c / cast(float) _colCount) * Math.PI2;
                col = FieldVec(angle, _stepLength);
            }
        }
    }

    void drawFlows(
        Vec2f[] points,
        scope bool delegate(Vec2f) onStartRowIsContinue,
        scope bool delegate(Vec2f) onLinePointIsContinue,
        scope bool delegate(Vec2f) onEndRowIsContinue,
    )
    {
        assert(onStartRowIsContinue);
        assert(onLinePointIsContinue);
        assert(onEndRowIsContinue);

        foreach (ref p; points)
        {
            float startX = p.x;
            float startY = p.y;

            if (!onStartRowIsContinue(p))
            {
                return;
            }

            foreach (n; 0 .. steps)
            {
                if (!onLinePointIsContinue(Vec2f(startX, startY)))
                {
                    return;
                }

                auto xOffset = startX - gridBounds.x;
                auto yOffset = startY - gridBounds.y;

                auto columnIndex = cast(size_t)(xOffset / resolution);
                auto rowIndex = cast(size_t)(yOffset / resolution);

                if (columnIndex >= _colCount || rowIndex >= _rowCount)
                {
                    continue;
                }

                auto gridVec = grid[rowIndex][columnIndex];
                Vec2f xyStep = gridVec.toVec2;
                startX += xyStep.x;
                startY += xyStep.y;
            }

            if (!onEndRowIsContinue(Vec2f(startX, startY)))
            {
                return;
            }
        }
    }

    void create(float startX, float startY)
    {
        createGrid(startX, startY);
        rotateGrid;
    }

    void drawGrid(scope void delegate(Vec2f, Vec2f) onLine)
    {
        if (grid.length == 0)
        {
            return;
        }

        float startY = gridBounds.y;
        foreach (ri, ref row; grid)
        {
            float startX = gridBounds.x;
            foreach (ci, ref col; row)
            {
                Vec2f startXY = Vec2f(startX, startY);
                Vec2f endXY = Vec2f.fromPolarRad(col.polarAngleRad, resolution);
                onLine(startXY, startXY.add(endXY));
                startX += resolution;
            }
            startY += resolution;
        }
    }

    void onGrid(scope bool delegate(ref FieldVec) onVecIsContinue)
    {
        foreach (ref FieldVec[] row; grid)
        {
            foreach (ref vec; row)
            {
                if (!onVecIsContinue(vec))
                {
                    return;
                }
            }
        }
    }

    void stepLength(float value)
    {
        _stepLength = value;
        if (grid.length == 0)
        {
            return;
        }

        onGrid((ref vec) { vec.length = value; return true; });
    }

}
