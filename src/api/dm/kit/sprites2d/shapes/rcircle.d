module api.dm.kit.sprites2d.shapes.rcircle;

import api.dm.kit.sprites2d.shapes.rshape2d;
import api.dm.kit.graphics.styles.gstyle : GStyle;
import api.math.geom2.circle2 : Circle2f;
import api.dm.kit.sprites2d.shapes.rrect : RRect;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;

/**
 * Authors: initkfs
 */
class RCircle : RShape2d
{
    const float radius;

    this(float radius = 25, GStyle style = GStyle.simple)
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

    Circle2f shape()
    {
        return Circle2f(x, y, radius);
    }

    override bool intersect(Sprite2d other)
    {
        //import api.core.utils.types : castSafe;
        //TODO unsafe cast, but fast
        if (auto circle = cast(RCircle) other)
        {
            return shape.intersect(circle.shape);
        }
        else if (auto rect = cast(RRect) other)
        {
            return other.boundsRect.intersect(shape);
        }

        return super.intersect(other);
    }
}
