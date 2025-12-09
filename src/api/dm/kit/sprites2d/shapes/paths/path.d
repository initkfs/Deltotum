module api.dm.kit.sprites2d.shapes.paths.path;

import api.dm.kit.sprites2d.shapes.shape2d : Shape2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.math.geom2.vec2 : Vec2f;

/**
 * Authors: initkfs
 */
class Path : Shape2d
{
    Vec2f[] points;
    bool isDrawPoints = false;

    this(float canvasWidth, float canvasHeight, GraphicStyle style)
    {
        super(canvasWidth, canvasHeight, style);
        debug
        {
            isDrawPoints = true;
        }
    }
}
