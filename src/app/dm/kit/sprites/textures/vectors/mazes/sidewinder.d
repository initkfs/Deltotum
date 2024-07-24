module app.dm.kit.sprites.textures.vectors.mazes.sidewinder;

import app.dm.kit.sprites.textures.vectors.mazes.maze: Maze;
import app.dm.kit.sprites.textures.vectors.mazes.maze_cell : MazeCell;
import app.dm.kit.sprites.textures.texture : Texture;
import app.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import app.dm.kit.graphics.colors.rgba : RGBA;
import app.dm.kit.graphics.colors.hsv : HSV;
import app.dm.gui.containers.hbox : HBox;
import app.dm.gui.containers.vbox : VBox;

import Math = app.dm.math;
import app.dm.math.random : Random;

import std.random : unpredictableSeed;

/**
 * Authors: initkfs
 * See https://habr.com/ru/articles/320140
 */
class Sidewinder : Maze
{
    this(double width = 100, double height = 100, size_t cellWidth = 10, size_t cellHeight = 10, uint seed = unpredictableSeed)
    {
        super(width, height, cellWidth, cellHeight, seed);
    }

    override void maze()
    {
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
    }

    private void resetSet(MazeCell[] set)
    {
        foreach (ref cell; set)
        {
            cell = null;
        }
    }
}
