module deltotum.kit.sprites.shapes.circle;

import deltotum.kit.sprites.shapes.shape;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.math.shapes.circle2d : Circle2d;
import deltotum.kit.sprites.shapes.rectangle : Rectangle;
import deltotum.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
class Circle : Shape
{
    const double radius;

    this(double radius, GraphicStyle style = GraphicStyle.simple)
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

        //TODO remove cast
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
