module api.dm.addon.procedural.mazes.shapes.sidewinder;

import api.dm.addon.procedural.mazes.shapes.maze: Maze;
import api.dm.addon.procedural.mazes.shapes.maze_cell : MazeCell;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.colors.hsva : HSVA;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.gui.controls.containers.vbox : VBox;

import Math = api.dm.math;
import api.math.random : Random;

import std.random : unpredictableSeed;

/**
 * Authors: initkfs
 * See https://habr.com/ru/articles/320140
 */
class Sidewinder : Maze
{
    this(float width = 100, float height = 100, size_t cellWidth = 10, size_t cellHeight = 10, uint seed = unpredictableSeed)
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
                        auto randCol = cast(size_t) rnd.between(setOffset, colIndex);
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
