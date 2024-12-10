module api.dm.addon.sprites.textures.vectors.mazes.maze_cell;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.colors.hsv : HSV;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
class MazeCell : Sprite2d
{
    Sprite2d texture;

    GraphicStyle style = GraphicStyle.simple;

    size_t row;
    size_t col;

    bool topWall;
    bool rightWall;
    bool bottomWall;
    bool leftWall;

    MazeCell topNeighbour;
    MazeCell rightNeighbour;
    MazeCell bottomNeighbour;
    MazeCell leftNeighbour;

    bool isVisited;

    this(double width = 100, double height = 100, bool isWall = false)
    {
        //super(width, height);
        topWall = isWall;
        rightWall = isWall;
        bottomWall = isWall;
        leftWall = isWall;
        this.width = width;
        this.height = height;
    }

    override void create()
    {
        super.create;
    }

    void createMazeWalls()
    {
        assert(width > 0);
        assert(height > 0);

        auto w = width;
        auto h = height;

        import api.dm.kit.sprites2d.textures.vectors.vector_texture : VectorTexture;

        texture = new class VectorTexture
        {
            this()
            {
                super(w, h);
            }

            override void createTextureContent()
            {
                import api.dm.kit.graphics.contexts.graphics_context : GraphicsContext;

                canvas.lineEnd(GraphicsContext.LineEnd.round);
                canvas.lineWidth(style.lineWidth);

                //TODO check if no walls
                //TODO auto padding = style.lineWidth / 2;
                if (topWall)
                {
                    canvas.moveTo(0, 0);
                    canvas.lineTo(width, 0);
                }

                if (rightWall)
                {
                    canvas.moveTo(width, 0);
                    canvas.lineTo(width, height);
                }

                if (bottomWall)
                {
                    canvas.moveTo(width, height);
                    canvas.lineTo(0, height);
                }

                if (leftWall)
                {
                    canvas.moveTo(0, height);
                    canvas.lineTo(0, 0);
                }

                if (style.isFill)
                {
                    canvas.color(style.fillColor);
                    canvas.fillPreserve;
                }

                canvas.color(style.lineColor);
                canvas.stroke;
            }
        };
        addCreate(texture);

    }

}
