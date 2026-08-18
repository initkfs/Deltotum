module api.dm.kit.sprites2d.shapes.paths.path;

import api.dm.kit.sprites2d.shapes.rshape2d : RShape2d;
import api.dm.kit.graphics.styles.gstyle : GStyle;
import api.math.geom2.vec2 : Vec2f;

/**
 * Authors: initkfs
 */
class Path : RShape2d
{
    Vec2f[] points;
    bool isDrawPoints = false;

    this(float canvasWidth, float canvasHeight, GStyle style)
    {
        super(canvasWidth, canvasHeight, style);
        debug
        {
            isDrawPoints = true;
        }
    }
}
