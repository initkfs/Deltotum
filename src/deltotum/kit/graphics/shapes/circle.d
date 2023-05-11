module deltotum.kit.graphics.shapes.circle;

import deltotum.kit.graphics.shapes.shape;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
class Circle : Shape
{
    this(double radius, GraphicStyle style)
    {
        super(radius * 2, radius * 2, style);
    }

    override void drawContent()
    {
        super.drawContent;
        double currentRadius = width / 2;
        double centerX = x + width / 2;
        double centerY = y + height / 2;
        graphics.drawCircle(centerX, centerY, currentRadius, style);
    }
}
