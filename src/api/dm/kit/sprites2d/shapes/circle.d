module api.dm.kit.sprites2d.shapes.circle;

import api.dm.kit.sprites2d.shapes.shape2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.math.geom2.circle2 : Circle2d;
import api.dm.kit.sprites2d.shapes.rectangle : Rectangle;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;

/**
 * Authors: initkfs
 */
class Circle : Shape2d
{
    const float radius;

    this(float radius = 25, GraphicStyle style = GraphicStyle.simple)
    {
        super(radius * 2, radius * 2, style);
        this.radius = radius;
    }

    override void drawContent()
    {
        super.drawContent;
        float currentRadius = width / 2;
        float centerX = x + width / 2;
        float centerY = y + height / 2;
        graphic.circle(centerX, centerY, currentRadius, style.lineColor, style.isFill);
    }

    Circle2d shape()
    {
        return Circle2d(x, y, radius);
    }

    override bool intersect(Sprite2d other)
    {
        //import api.core.utils.types : castSafe;
        //TODO unsafe cast, but fast
        if (auto circle = cast(Circle) other)
        {
            return shape.intersect(circle.shape);
        }
        else if (auto rect = cast(Rectangle) other)
        {
            return other.boundsRect.intersect(shape);
        }

        return super.intersect(other);
    }
}
