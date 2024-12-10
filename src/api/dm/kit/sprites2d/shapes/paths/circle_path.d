module api.dm.kit.sprites2d.shapes.paths.circle_path;

import api.dm.kit.sprites2d.shapes.paths.path : Path;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
class CirclePath : Path
{
    int radius;

    this(int radius, GraphicStyle style)
    {
        super(radius * 2, radius * 2, style);
        this.radius = radius;
    }

    override void drawContent()
    {
        super.drawContent;
        if (isDrawPoints)
        {
            foreach (p; points)
            {
                graphics.point(x + p.x, y + p.y, style.lineColor);
            }
        }
    }

    override void create()
    {
        import math = api.dm.math;
        import api.math.geom2.vec2 : Vec2d;

        foreach (angleDeg; 1 .. 361)
        {
            immutable pX = width / 2 + radius * math.cosDeg(angleDeg);
            immutable pY = height / 2 + radius * math.sinDeg(angleDeg);
            points ~= Vec2d(pX, pY);
        }
        super.create;
    }
}
