module dm.kit.sprites.shapes.paths.path;

import dm.kit.sprites.shapes.shape : Shape;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;
import dm.math.vector2 : Vector2;

/**
 * Authors: initkfs
 */
class Path : Shape
{
    Vector2[] points;
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
