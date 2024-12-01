module api.dm.addon.sprites.textures.vectors.mazes.maze;

import api.dm.addon.sprites.textures.vectors.mazes.maze_cell : MazeCell;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.colors.hsv : HSV;
import api.dm.gui.containers.hbox : HBox;
import api.dm.gui.containers.vbox : VBox;

import Math = api.dm.math;
import api.math.random : Random;
import std.conv : to;

import std.random : unpredictableSeed;

/**
 * Authors: initkfs
 */
abstract class Maze : Sprite2d
{
    size_t cellWidth;
    size_t cellHeight;

    GraphicStyle cellStyle = GraphicStyle(4, RGBA.white, true, RGBA.red);

    protected
    {
        size_t mazeWidth;
        size_t mazeHeight;
        size_t cellRows;
        size_t cellCols;

        size_t lastRowIndex;
        size_t lastColIndex;

        MazeCell[][] cells;

        Random rnd;
    }

    this(double width = 100, double height = 100, size_t cellWidth = 10, size_t cellHeight = 10, uint seed = unpredictableSeed)
    {
        assert(width > 0);
        assert(height > 0);

        this.width = width;
        this.height = height;

        assert(cellWidth > 0);
        assert(cellHeight > 0);

        this.cellWidth = cellWidth;
        this.cellHeight = cellHeight;

        //TODO seed
        rnd = new Random(seed);
    }

    override void create()
    {
        super.create;

        createMazeGeometry;
        createMazeCells;

        maze;

        foreach (rowIndex; 0 .. cellRows)
        {
            foreach (colIndex; 0 .. cellCols)
            {
                auto cell = cells[rowIndex][colIndex];
                cell.createMazeWalls;
            }
        }
    }

    abstract void maze();

    void createMazeGeometry()
    {
        assert(width > 0);
        assert(height > 0);

        mazeWidth = width.to!size_t;
        mazeHeight = height.to!size_t;

        assert(cellWidth > 0);
        assert(cellHeight > 0);

        cellRows = cast(size_t)(mazeHeight / cellHeight);
        cellCols = cast(size_t)(mazeWidth / cellWidth);

        assert(cellRows > 1);
        assert(cellCols > 1);

        //TODO check for reuse
        cells = new MazeCell[][](cellRows, cellCols);

        lastRowIndex = cellRows - 1;
        lastColIndex = cellCols - 1;
    }

    void createMazeCells()
    {
        //TODO reuse
        auto rowContainer = new VBox(0);
        addCreate(rowContainer);

        foreach (rowIndex; 0 .. cellRows)
        {
            auto colContainer = new HBox(0);
            rowContainer.addCreate(colContainer);
            foreach (colIndex; 0 .. cellCols)
            {
                auto cell = new MazeCell(cellWidth, cellHeight, true);
                cell.style = cellStyle;
                colContainer.addCreate(cell);
                cells[rowIndex][colIndex] = cell;

                if (rowIndex != 0)
                {
                    auto prevRow = cells[rowIndex - 1];
                    auto topNeighbour = prevRow[colIndex];
                    if (!topNeighbour.bottomNeighbour)
                    {
                        topNeighbour.bottomNeighbour = cell;
                    }

                    cell.topNeighbour = topNeighbour;
                }

                if (colIndex != 0)
                {
                    auto prevCol = cells[rowIndex][colIndex - 1];
                    if (!prevCol.rightNeighbour)
                    {
                        prevCol.rightNeighbour = cell;
                    }
                    cell.leftNeighbour = prevCol;
                }
            }
        }
    }
}
