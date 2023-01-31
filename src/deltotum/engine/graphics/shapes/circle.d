module deltotum.engine.graphics.shapes.circle;

import deltotum.engine.graphics.shapes.shape;
import deltotum.engine.graphics.styles.graphic_style: GraphicStyle;

/**
 * Authors: initkfs
 */
class Circle : Shape
{
    double radius = 0;

    this(double radius, GraphicStyle style, double borderWidth = 1.0)
    {
        super(radius * 2 + borderWidth, radius * 2 + borderWidth, style);
        this.radius = radius;
    }

    override void createTextureContent()
    {
        graphics.drawCircle(width / 2, height / 2, radius, style);
    }
}
