module deltotum.kit.graphics.shapes.circle;

import deltotum.kit.graphics.shapes.shape;
import deltotum.kit.graphics.styles.graphic_style: GraphicStyle;

/**
 * Authors: initkfs
 */
class Circle : Shape
{
    double radius = 0;

    this(double radius, GraphicStyle style)
    {
        super(radius * 2, radius * 2, style);
        this.radius = radius;
    }

    override void createTextureContent()
    {
        graphics.drawCircle(width / 2, height / 2, radius, style);
    }
}
