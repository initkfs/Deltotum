module api.dm.kit.sprites2d.shapes.points_shape;

import api.dm.kit.sprites2d.shapes.shape2d : Shape2d;

import api.math.geom2.vec2 : Vec2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
class PointsShape : Shape2d
{
    bool isClosePath;
    bool isDrawFromCenter;

    Vec2d[] points;

    this(double width = 100, double height = 100, GraphicStyle style = GraphicStyle.simple, Vec2d[] points = null, bool isClosePath = false, bool isDrawFromCenter = false)
    {
        super(width, height, style);
        this.isClosePath = isClosePath;
        this.isDrawFromCenter = isDrawFromCenter;
        this.points = points;
    }

    override void drawContent()
    {
        import api.dm.kit.graphics.colors.rgba : RGBA;

        if (points.length < 2)
        {
            return;
        }

        const double firstX = points[0].x, firstY = points[0].y;

        const thisBounds = boundsRect;

        double offsetX = thisBounds.x, offsetY = thisBounds.y;
        if (isDrawFromCenter)
        {
            if (width > 0)
            {
                offsetX += width / 2;
            }

            if(height > 0){
                offsetY += height / 2;
            }

        }

        double startX = firstX, startY = firstY;
        foreach (p; points[1 .. $])
        {
            graphic.line(offsetX + startX, offsetY + startY, offsetX + p.x, offsetY + p.y);
            startX = p.x;
            startY = p.y;
        }

        if (isClosePath)
        {
            graphic.line(offsetX + startX, offsetY + startY, offsetX + firstX, offsetY +  firstY);
        }
    }
}
