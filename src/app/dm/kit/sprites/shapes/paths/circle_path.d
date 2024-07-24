module app.dm.kit.sprites.shapes.paths.circle_path;

import app.dm.kit.sprites.shapes.paths.path : Path;
import app.dm.kit.graphics.styles.graphic_style : GraphicStyle;

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
        import math = app.dm.math;
        import app.dm.math.vector2 : Vector2;

        foreach (angleDeg; 1 .. 361)
        {
            immutable pX = width / 2 + radius * math.cosDeg(angleDeg);
            immutable pY = height / 2 + radius * math.sinDeg(angleDeg);
            points ~= Vector2(pX, pY);
        }
        super.create;
    }
}
