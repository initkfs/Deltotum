module deltotum.graphics.shapes.shape;

import deltotum.graphics.draw.canvas: Canvas;
import deltotum.graphics.styles.graphic_style: GraphicStyle;

/**
 * Authors: initkfs
 */
class Shape : Canvas
{
    @property GraphicStyle style;

    this(double width, double height, GraphicStyle style)
    {
        super(width, height);
        this.style = style;
    }
}
