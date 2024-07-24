module app.dm.kit.sprites.shapes.paths.path;

import app.dm.kit.sprites.shapes.shape : Shape;
import app.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import app.dm.math.vector2 : Vector2;

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
