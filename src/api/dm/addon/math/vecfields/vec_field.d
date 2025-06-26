module api.dm.addon.math.vecfields.vec_field;

import api.math.geom2.rect2 : Rect2d;
import api.math.geom2.vec2 : Vec2d;

import Math = api.math;

struct FieldVec
{
    double polarAngleRad = 0;
    double length = 0;

    Vec2d toVec2() => Vec2d.fromPolarRad(polarAngleRad, length);
}

/**
 * Authors: initkfs
 */
class VecField
{
    Rect2d gridBounds;
    FieldVec[][] grid;

    size_t steps = 20;
    double resolution = 5;

    protected
    {
        size_t _colCount;
        size_t _rowCount;

        double _width = 0;
        double _height = 0;

        double _stepLength = 0;
    }

    this(double fieldWidth = 100, double fieldHeight = 100)
    {
        _width = fieldWidth;
        _height = fieldHeight;
    }

    void createGrid(double startX, double startY)
    {
        auto leftX = _width * -0.5;
        auto rightX = _width * 1.5;
        auto topY = _height * -0.5;
        auto bottomY = _height * 1.5;
        resolution = _width * 0.05;
        _colCount = cast(size_t)((rightX - leftX) / resolution);
        _rowCount = cast(size_t)((bottomY - topY) / resolution);

        gridBounds = Rect2d(startX + leftX, startY + topY, rightX - leftX, bottomY - topY);

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
                const angle = (c / cast(double) _colCount) * Math.PI2;
                col = FieldVec(angle, _stepLength);
            }
        }
    }

    void drawFlows(
        Vec2d[] points,
        scope bool delegate(Vec2d) onStartRowIsContinue,
        scope bool delegate(Vec2d) onLinePointIsContinue,
        scope bool delegate(Vec2d) onEndRowIsContinue,
    )
    {
        assert(onStartRowIsContinue);
        assert(onLinePointIsContinue);
        assert(onEndRowIsContinue);

        foreach (ref p; points)
        {
            double startX = p.x;
            double startY = p.y;

            if (!onStartRowIsContinue(p))
            {
                return;
            }

            foreach (n; 0 .. steps)
            {
                if (!onLinePointIsContinue(Vec2d(startX, startY)))
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
                Vec2d xyStep = gridVec.toVec2;
                startX += xyStep.x;
                startY += xyStep.y;
            }

            if (!onEndRowIsContinue(Vec2d(startX, startY)))
            {
                return;
            }
        }
    }

    void create(double startX, double startY)
    {
        createGrid(startX, startY);
        rotateGrid;
    }

    void drawGrid(scope void delegate(Vec2d, Vec2d) onLine)
    {
        if (grid.length == 0)
        {
            return;
        }

        double startY = gridBounds.y;
        foreach (ri, ref row; grid)
        {
            double startX = gridBounds.x;
            foreach (ci, ref col; row)
            {
                Vec2d startXY = Vec2d(startX, startY);
                Vec2d endXY = Vec2d.fromPolarRad(col.polarAngleRad, resolution);
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

    void stepLength(double value)
    {
        _stepLength = value;
        if (grid.length == 0)
        {
            return;
        }

        onGrid((ref vec) { vec.length = value; return true; });
    }

}
