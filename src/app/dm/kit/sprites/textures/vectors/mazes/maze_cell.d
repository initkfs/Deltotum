module app.dm.kit.sprites.textures.vectors.mazes.maze_cell;

import app.dm.kit.sprites.sprite : Sprite;
import app.dm.kit.graphics.colors.rgba : RGBA;
import app.dm.kit.graphics.colors.hsv : HSV;
import app.dm.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
class MazeCell : Sprite
{
    Sprite texture;

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

        import app.dm.kit.sprites.textures.vectors.vector_texture : VectorTexture;

        texture = new class VectorTexture
        {
            this()
            {
                super(w, h);
            }

            override void createTextureContent()
            {
                import app.dm.kit.graphics.contexts.graphics_context : GraphicsContext;

                gContext.setLineEnd(GraphicsContext.LineEnd.round);
                gContext.setLineWidth(style.lineWidth);

                //TODO check if no walls
                //TODO auto padding = style.lineWidth / 2;
                if (topWall)
                {
                    gContext.moveTo(0, 0);
                    gContext.lineTo(width, 0);
                }

                if (rightWall)
                {
                    gContext.moveTo(width, 0);
                    gContext.lineTo(width, height);
                }

                if (bottomWall)
                {
                    gContext.moveTo(width, height);
                    gContext.lineTo(0, height);
                }

                if (leftWall)
                {
                    gContext.moveTo(0, height);
                    gContext.lineTo(0, 0);
                }

                if (style.isFill)
                {
                    gContext.setColor(style.fillColor);
                    gContext.fillPreserve;
                }

                gContext.setColor(style.lineColor);
                gContext.stroke;
            }
        };
        addCreate(texture);

    }

}
