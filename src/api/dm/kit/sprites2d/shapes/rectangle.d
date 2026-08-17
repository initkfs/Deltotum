module api.dm.kit.sprites2d.shapes.rectangle;

import api.dm.kit.sprites2d.shapes.shape2d;
import api.dm.kit.graphics.styles.gstyle : GStyle;
import api.dm.kit.sprites2d.shapes.circle : Circle;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;

/**
 * Authors: initkfs
 */
class Rectangle : Shape2d
{
    this(float width, float height, GStyle style)
    {
        super(width, height, style);
    }

    this(float width, float height)
    {
        super(width, height, GStyle.simple);
    }

    override void drawContent()
    {
        import api.dm.kit.graphics.colors.rgba : RGBA;

        const lineWidth = style.lineWidth;
        graphic.rect(x, y, width, height, style.lineColor);
        if (style.isFill)
        {
            graphic.fillRect(x + lineWidth, y + lineWidth, width - lineWidth * 2, height - lineWidth * 2, style
                    .fillColor);
        }
    }

    override bool intersect(Sprite2d other)
    {
        //TODO unsafe cast, but fast
        if (auto circle = cast(Circle) other)
        {
            return boundsRect.intersect(circle.shape);
        }

        return super.intersect(other);
    }
}
