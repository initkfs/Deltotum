module deltotum.graphics.shape.rectangle;

import deltotum.graphics.shape.shape;
import deltotum.graphics.styles.graphic_style: GraphicStyle;

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
