module deltotum.kit.graphics.shapes.paths.path;

import deltotum.kit.graphics.shapes.shape : Shape;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.math.vector2d : Vector2d;

/**
 * Authors: initkfs
 */
class Path : Shape
{
    Vector2d[] points;
    bool isDrawPoints = false;

    this(double canvasWidth, double canvasHeight, GraphicStyle style)
    {
        super(canvasWidth, canvasHeight, style);
        debug
        {
            isDrawPoints = true;
        }
    }
}
