module deltotum.kit.graphics.shapes.shape;

import deltotum.kit.graphics.draw.canvas : Canvas;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
class Shape : Canvas
{
    //TODO remove from shape
    GraphicStyle style;

    this(double width, double height, GraphicStyle style)
    {
        super(width, height);
        this.style = style;
    }
}
