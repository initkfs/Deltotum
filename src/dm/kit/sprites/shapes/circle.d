module dm.kit.sprites.shapes.circle;

import dm.kit.sprites.shapes.shape;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;
import dm.math.circle2d : Circle2d;
import dm.kit.sprites.shapes.rectangle : Rectangle;
import dm.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
class Circle : Shape
{
    const double radius;

    this(double radius = 25, GraphicStyle style = GraphicStyle.simple)
    {
        super(radius * 2, radius * 2, style);
        this.radius = radius;
    }

    override void drawContent()
    {
        super.drawContent;
        double currentRadius = width / 2;
        double centerX = x + width / 2;
        double centerY = y + height / 2;
        graphics.circle(centerX, centerY, currentRadius, style.lineColor, style.isFill);
    }

    Circle2d shape()
    {
        return Circle2d(x, y, radius);
    }

    override bool intersect(Sprite other)
    {
        //import dm.core.utils.type_util : castSafe;
        //TODO unsafe cast, but fast
        if (auto circle = cast(Circle) other)
        {
            return shape.intersect(circle.shape);
        }
        else if (auto rect = cast(Rectangle) other)
        {
            return other.bounds.intersect(shape);
        }

        return super.intersect(other);
    }
}
