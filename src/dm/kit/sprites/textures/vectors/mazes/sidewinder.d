module dm.kit.sprites.textures.vectors.mazes.sidewinder;

import dm.kit.sprites.textures.vectors.mazes.maze_cell : MazeCell;
import dm.kit.sprites.textures.texture : Texture;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;
import dm.kit.graphics.colors.rgba : RGBA;
import dm.kit.graphics.colors.hsv : HSV;
import dm.gui.containers.hbox : HBox;
import dm.gui.containers.vbox : VBox;

import Math = dm.math;
import dm.math.random : Random;

/**
 * Authors: initkfs
 */
class Sidewinder : Texture
{
    Random rnd;
    MazeCell[][] cells;
    double cellWidth = 0;
    double cellHeight = 0;

    this(double width = 100, double height = 100, double cellWidth = 10, double cellHeight = 10)
    {
        super(width, height);
        this.cellWidth = cellWidth;
        this.cellHeight = cellHeight;
        //TODO seed
        rnd = new Random;
    }

    override void create()
    {
        super.create;

        //createMutRGBA32;
        //assert(texture);

        assert(width > 0);
        assert(height > 0);

        size_t h = cast(size_t) height;
        size_t w = cast(size_t) width;

        assert(cellWidth > 0);
        assert(cellHeight > 0);

        size_t cellRows = cast(size_t)(h / cellHeight);
        size_t cellCols = cast(size_t)(w / cellWidth);

        cells = new MazeCell[][](cellRows, cellCols);

        assert(cellRows > 1);
        assert(cellCols > 1);

        size_t lastRowIndex = cellRows - 1;
        size_t lastColIndex = cellCols - 1;

        auto rowContainer = new VBox(0);
        addCreate(rowContainer);

        foreach (rowIndex; 0 .. cellRows)
        {
            auto colContainer = new HBox(0);
            rowContainer.addCreate(colContainer);
            foreach (colIndex; 0 .. cellCols)
            {
                auto cell = new MazeCell(cellWidth, cellHeight, true);
                cell.style = GraphicStyle(3, RGBA.lightgreen, true, RGBA.lightblue);
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

        size_t setOffset = 0;
        foreach (rowIndex; 0 .. cellRows)
        {
            for (size_t colIndex = 0; colIndex < cellCols; colIndex++)
            {
                auto cell = cells[rowIndex][colIndex];

                if (rowIndex != 0)
                {
                    if (!rnd.chanceHalf && colIndex != lastColIndex)
                    {
                        cell.rightWall = false;
                        cells[rowIndex][colIndex + 1].leftWall = false;
                    }
                    else
                    {
                        auto randCol = cast(size_t) rnd.randomBetween(setOffset, colIndex);
                        cells[rowIndex - 1][randCol].bottomWall = false;
                        cells[rowIndex][randCol].topWall = false;

                        if (colIndex != lastColIndex)
                        {
                            setOffset = colIndex + 1;
                        }
                        else
                        {
                            setOffset = 0;
                        }
                    }

                }
                else
                {
                    if (colIndex != lastColIndex)
                    {
                        cell.rightWall = false;
                        cells[rowIndex][colIndex + 1].leftWall = false;
                    }
                }

            }
        }

        foreach (rowIndex; 0 .. cellRows)
        {
            foreach (colIndex; 0 .. cellCols)
            {
                auto cell = cells[rowIndex][colIndex];
                cell.createMazeWalls;
            }
        }
    }

    private void resetSet(MazeCell[] set)
    {
        foreach (ref cell; set)
        {
            cell = null;
        }
    }
}
