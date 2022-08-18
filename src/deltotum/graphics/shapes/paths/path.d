module deltotum.graphics.shapes.paths.path;

import deltotum.graphics.shapes.shape : Shape;
import deltotum.graphics.styles.graphic_style : GraphicStyle;
import deltotum.math.vector2d : Vector2d;

/**
 * Authors: initkfs
 */
class Path : Shape
{
    @property Vector2d[] points = [];
    @property bool isDrawPoints = false;

    this(double canvasWidth, double canvasHeight, GraphicStyle style)
    {
        super(canvasWidth, canvasHeight, style);
        debug
        {
            isDrawPoints = true;
        }
    }
}
