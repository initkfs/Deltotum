module dm.kit.sprites.textures.vectors.mazes.maze_cell;

import dm.kit.sprites.sprite : Sprite;
import dm.kit.graphics.colors.rgba : RGBA;
import dm.kit.graphics.colors.hsv : HSV;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;

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

        import dm.kit.sprites.textures.vectors.vector_texture : VectorTexture;

        texture = new class VectorTexture
        {
            this()
            {
                super(w, h);
            }

            override void createTextureContent()
            {
                if (style.isFill)
                {
                    gContext.setColor(style.fillColor);
                }

                gContext.setLineWidth(style.lineWidth);

                //TODO lineWidth

                if (topWall)
                {
                    gContext.moveTo(0, 0);
                    gContext.lineTo(width, 0);
                    gContext.strokePreserve;
                }

                if (rightWall)
                {
                    gContext.moveTo(width, 0);
                    gContext.lineTo(width, height);
                    gContext.strokePreserve;
                }

                if (bottomWall)
                {
                    gContext.moveTo(width, height);
                    gContext.lineTo(0, height);
                    gContext.strokePreserve;
                }

                if (leftWall)
                {
                    gContext.moveTo(0, height);
                    gContext.lineTo(0, 0);
                    gContext.strokePreserve;
                }

                if (style.isFill)
                {
                    gContext.fillPreserve;
                }

                gContext.stroke;
            }
        };
        addCreate(texture);

    }

}
