module api.dm.kit.sprites.shapes.paths.path;

import api.dm.kit.sprites.shapes.shape : Shape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.math.geom2.vec2 : Vec2d;

/**
 * Authors: initkfs
 */
class Path : Shape
{
    Vec2d[] points;
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
