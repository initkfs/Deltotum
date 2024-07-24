module app.dm.kit.sprites.shapes.rectangle;

import app.dm.kit.sprites.shapes.shape;
import app.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import app.dm.kit.sprites.shapes.circle : Circle;
import app.dm.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
class Rectangle : Shape
{
    this(double width, double height, GraphicStyle style)
    {
        super(width, height, style);
    }

    this(double width, double height)
    {
        super(width, height, GraphicStyle.simple);
    }

    override void drawContent()
    {
        import app.dm.kit.graphics.colors.rgba : RGBA;

        const lineWidth = style.lineWidth;
        graphics.rect(x, y, width, height, style.lineColor);
        if (style.isFill)
        {
            graphics.fillRect(x + lineWidth, y + lineWidth, width - lineWidth * 2, height - lineWidth * 2, style
                    .fillColor);
        }
    }

    override bool intersect(Sprite other)
    {
        //TODO unsafe cast, but fast
        if (auto circle = cast(Circle) other)
        {
            return bounds.intersect(circle.shape);
        }

        return super.intersect(other);
    }
}
