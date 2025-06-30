module api.dm.addon.procedural.mazes.shapes.aldous_broder;

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
 * https://habr.com/ru/articles/321210/
 */
class AldousBroder : Maze
{
     this(double width = 100, double height = 100, size_t cellWidth = 10, size_t cellHeight = 10, uint seed = unpredictableSeed)
    {
        super(width, height, cellWidth, cellHeight, seed);
    }

    override void maze()
    {
        foreach (rowIndex; 0 .. cellRows)
        {
            for (size_t colIndex = 0; colIndex < cellCols; colIndex++)
            {
                auto cell = cells[rowIndex][colIndex];

            }
        }

        size_t unvisited_cells = cellCols * cellRows;
        size_t ix = rnd.between(0, lastColIndex);
        size_t iy = rnd.between(0, lastRowIndex);

        cells[iy][ix].isVisited = true;

        unvisited_cells--;

        string[] dirs = ["UP", "DOWN", "LEFT", "RIGHT"];

        while (unvisited_cells != 0)
        {
            auto dir = dirs[rnd.between(0, 3)];

            if (dir == "UP")
            {
                if (iy > 0)
                {
                    if (!cells[iy - 1][ix].isVisited)
                    {
                        cells[iy - 1][ix].bottomWall = false;
                        if(iy < lastRowIndex){
                            cells[iy][ix].topWall = false;
                        }
                        cells[iy - 1][ix].isVisited = true;
                        unvisited_cells--;
                    }
                    
                    iy = iy-1;
                }
            }
            else if (dir == "DOWN")
            {
                if ((iy + 1) <= lastRowIndex)
                {
                    if (!cells[iy + 1][ix].isVisited)
                    {
                        cells[iy][ix].bottomWall = false;
                        cells[iy + 1][ix].topWall = false;
                        cells[iy + 1][ix].isVisited = true;
                        unvisited_cells = unvisited_cells - 1;
                    }
                    iy = iy + 1;
                }

            }
            else if (dir == "RIGHT")
            {
                if ((ix + 1) <= lastColIndex)
                {
                    if (!cells[iy][ix + 1].isVisited)
                    {
                        cells[iy][ix].rightWall = false;
                        cells[iy][ix + 1].leftWall = false;
                        cells[iy][ix + 1].isVisited = true;
                        unvisited_cells = unvisited_cells - 1;
                    }
                    ix = ix + 1;
                }
            }
            else if (dir == "LEFT")
            {
                if (ix > 0)
                {
                    if (!cells[iy][ix - 1].isVisited)
                    {
                        cells[iy][ix - 1].rightWall = false;
                        cells[iy][ix].leftWall = false;
                        cells[iy][ix - 1].isVisited = true;
                        unvisited_cells = unvisited_cells - 1;
                    }
                    ix = ix - 1;
                }

            }

        }
    }
}
