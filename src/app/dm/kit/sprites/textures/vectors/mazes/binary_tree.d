module app.dm.kit.sprites.textures.vectors.mazes.binary_tree;

import app.dm.kit.sprites.textures.vectors.mazes.maze : Maze;
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
