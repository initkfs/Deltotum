module api.dm.kit.sprites.shapes.parallelogram;

import api.dm.kit.sprites.shapes.shape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites.shapes.circle : Circle;
import api.dm.kit.sprites.sprite : Sprite;
import api.math.geom2.parallelogram2 : Parallelogram2d;

/**
 * Authors: initkfs
 */
class Parallelogram : Shape
{
    double angleDeg;

    protected {
        Parallelogram2d shape;
    }

    this(double width, double height, double angleDeg ,GraphicStyle style)
    {
        super(width, height, style);
        this.angleDeg = angleDeg;
    }

    override void drawContent()
    {
        import api.dm.kit.graphics.colors.rgba : RGBA;

        super.drawContent;
        
        graphics.changeColor(style.lineColor);
        scope (exit)
        {
            graphics.restoreColor;
        }

        double prevX;
        double prevY;

        double firstX;
        double firstY;

        shape.draw(width, height, angleDeg, (i, p) {
            double endX = x + p.x;
            double endY = y + p.y;
            if (i == 0)
            {
                firstX = endX;
                firstY = endY;
            }
            else
            {
                graphics.line(prevX, prevY, endX, endY);
            }

            prevX = endX;
            prevY = endY;

            return true;
        });

        graphics.line(prevX, prevY, firstX, firstY);
    }
}
