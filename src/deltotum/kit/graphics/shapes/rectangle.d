module deltotum.kit.graphics.shapes.rectangle;

import deltotum.kit.graphics.shapes.shape;
import deltotum.kit.graphics.styles.graphic_style: GraphicStyle;

/**
 * Authors: initkfs
 */
class Rectangle : Shape
{
    this(double width, double height, GraphicStyle style)
    {
        super(width, height, style);
    }

    override void createTextureContent()
    {
       graphics.drawRect(0, 0, width, height, style);
    }
}
