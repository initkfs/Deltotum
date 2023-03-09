module deltotum.toolkit.graphics.shapes.shape;

import deltotum.toolkit.graphics.draw.canvas: Canvas;
import deltotum.toolkit.graphics.styles.graphic_style: GraphicStyle;

/**
 * Authors: initkfs
 */
class Shape : Canvas
{
    GraphicStyle style;

    this(double width, double height, GraphicStyle style)
    {
        super(width, height);
        this.style = style;
    }
}
