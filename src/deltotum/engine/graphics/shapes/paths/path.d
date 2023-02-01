module deltotum.engine.graphics.shapes.paths.path;

import deltotum.engine.graphics.shapes.shape : Shape;
import deltotum.engine.graphics.styles.graphic_style : GraphicStyle;
import deltotum.core.maths.vector2d : Vector2d;

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
