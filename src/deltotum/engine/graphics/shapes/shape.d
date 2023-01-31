module deltotum.engine.graphics.shapes.shape;

import deltotum.engine.graphics.draw.canvas: Canvas;
import deltotum.engine.graphics.styles.graphic_style: GraphicStyle;

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
