module deltotum.kit.graphics.shapes.paths.circle_path;

import deltotum.kit.graphics.shapes.paths.path : Path;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

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

    override void createTextureContent()
    {
        if (isDrawPoints)
        {
            graphics.drawPoints(points, style.lineColor);
        }
    }

    override void create()
    {
        import math = deltotum.math.math;
        import deltotum.math.vector2d : Vector2d;

        foreach (angleDeg; 1 .. 361)
        {
            immutable pX = width / 2 + radius * math.cosDeg(angleDeg);
            immutable pY = height / 2 + radius * math.sinDeg(angleDeg);
            points ~= Vector2d(pX, pY);
        }
        super.create;
    }
}
