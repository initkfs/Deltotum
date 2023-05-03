module deltotum.kit.graphics.vectors.shapes.shape;

import deltotum.kit.graphics.canvases.drawable_canvas : DrawableCanvas;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
class Shape : DrawableCanvas
{
    //TODO remove from shape
    GraphicStyle style;

    this(double width, double height, GraphicStyle style)
    {
        super(width, height);
        this.style = style;
    }
}
