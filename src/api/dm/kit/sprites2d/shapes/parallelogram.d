module api.dm.kit.sprites2d.shapes.parallelogram;

import api.dm.kit.sprites2d.shapes.shape2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites2d.shapes.circle : Circle;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.math.geom2.parallelogram2 : Parallelogram2f;

/**
 * Authors: initkfs
 */
class Parallelogram : Shape2d
{
    float angleDeg;
    bool isInverted;

    protected {
        Parallelogram2f shape;
    }

    this(float width, float height, float angleDeg, bool isInverted, GraphicStyle style)
    {
        super(width, height, style);
        this.angleDeg = angleDeg;
        this.isInverted = isInverted;
    }

    override void drawContent()
    {
        import api.dm.kit.graphics.colors.rgba : RGBA;

        super.drawContent;
        
        graphic.color(style.lineColor);
        scope (exit)
        {
            graphic.restoreColor;
        }

        float prevX;
        float prevY;

        float firstX;
        float firstY;

        shape.draw(width, height, angleDeg, isInverted, (i, p) {
            float endX = x + p.x;
            float endY = y + p.y;
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
