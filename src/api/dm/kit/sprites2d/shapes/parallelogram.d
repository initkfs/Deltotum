module api.dm.kit.sprites2d.shapes.parallelogram;

import api.dm.kit.sprites2d.shapes.shape2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites2d.shapes.circle : Circle;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.math.geom2.parallelogram2 : Parallelogram2d;

/**
 * Authors: initkfs
 */
class Parallelogram : Shape2d
{
    double angleDeg;
    bool isInverted;

    protected {
        Parallelogram2d shape;
    }

    this(double width, double height, double angleDeg, bool isInverted, GraphicStyle style)
    {
        super(width, height, style);
        this.angleDeg = angleDeg;
        this.isInverted = isInverted;
    }

    override void drawContent()
    {
        import api.dm.kit.graphics.colors.rgba : RGBA;

        super.drawContent;
        
        graphic.changeColor(style.lineColor);
        scope (exit)
        {
            graphic.restoreColor;
        }

        double prevX;
        double prevY;

        double firstX;
        double firstY;

        shape.draw(width, height, angleDeg, isInverted, (i, p) {
            double endX = x + p.x;
            double endY = y + p.y;
            if (i == 0)
            {
                firstX = endX;
                firstY = endY;
            }
            else
            {
                graphic.line(prevX, prevY, endX, endY);
            }

            prevX = endX;
            prevY = endY;

            return true;
        });

        graphic.line(prevX, prevY, firstX, firstY);
    }
}
