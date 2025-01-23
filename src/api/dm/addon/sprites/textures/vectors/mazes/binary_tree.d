module api.dm.addon.sprites.textures.vectors.mazes.binary_tree;

import api.dm.addon.sprites.textures.vectors.mazes.maze : Maze;
import api.dm.addon.sprites.textures.vectors.mazes.maze_cell : MazeCell;
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
class BinaryTree : Maze
{
    this(double width = 100, double height = 100, size_t cellWidth = 10, size_t cellHeight = 10, uint seed = unpredictableSeed)
    {
        super(width, height, cellWidth, cellHeight, seed);
    }

    override void maze()
    {
        foreach (rowIndex; 0 .. cellRows)
        {
            foreach (colIndex; 0 .. cellCols)
            {
                auto cell = cells[rowIndex][colIndex];
                if (rowIndex == 0)
                {
                    if (colIndex != lastColIndex)
                    {
                        cell.rightWall = false;
                        auto nextCell = cells[rowIndex][colIndex + 1];
                        nextCell.leftWall = false;
                    }
                }
                else
                {
                    if (colIndex == lastColIndex)
                    {
                        cell.topWall = false;
                        auto topCell = cells[rowIndex - 1][colIndex];
                        topCell.bottomWall = false;
                    }

                    if (rnd.chanceHalf)
                    {
                        cell.topWall = false;
                        auto topCell = cells[rowIndex - 1][colIndex];
                        topCell.bottomWall = false;
                    }
                    else
                    {
                        if (colIndex != lastColIndex)
                        {
                            cell.rightWall = false;
                            auto nextCell = cells[rowIndex][colIndex + 1];
                            nextCell.leftWall = false;
                        }
                        else
                        {
                            cells[rowIndex - 1][colIndex].bottomWall = false;
                            cell.topWall = false;
                        }
                    }
                }
            }
        }
    }
}
