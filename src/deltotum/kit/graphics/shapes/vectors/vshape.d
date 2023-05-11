module deltotum.kit.graphics.shapes.vectors.vshape;

import deltotum.kit.graphics.canvases.vector_canvas : VectorCanvas;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
class VShape : VectorCanvas
{
    //TODO remove from shape
    GraphicStyle style;

    this(double width, double height, GraphicStyle style)
    {
        super(width, height);
        this.style = style;

        //TODO exception
        isResizable = false;
    }
}
