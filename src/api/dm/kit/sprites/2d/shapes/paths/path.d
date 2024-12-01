module api.dm.kit.sprites.sprites2d.shapes.paths.path;

import api.dm.kit.sprites.sprites2d.shapes.shape2d : Shape2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.math.geom2.vec2 : Vec2d;

/**
 * Authors: initkfs
 */
class Path : Shape2d
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
