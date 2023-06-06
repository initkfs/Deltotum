module deltotum.kit.graphics.shapes.points_shape;

import deltotum.kit.graphics.shapes.shape : Shape;

import deltotum.math.vector2d : Vector2d;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
class PointsShape : Shape
{
    bool isClosePath;
    bool isDrawFromCenter;

    Vector2d[] points;

    this(double width = 100, double height = 100, GraphicStyle style = GraphicStyle.simple, Vector2d[] points = null, bool isClosePath = false, bool isDrawFromCenter = false)
    {
        super(width, height, style);
        this.isClosePath = isClosePath;
        this.isDrawFromCenter = isDrawFromCenter;
        this.points = points;
    }

    override void drawContent()
    {
        import deltotum.kit.graphics.colors.rgba : RGBA;

        if (points.length < 2)
        {
            return;
        }

        const double firstX = points[0].x, firstY = points[0].y;

        const thisBounds = bounds;

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
            graphics.drawLine(offsetX + startX, offsetY + startY, offsetX + p.x, offsetY + p.y);
            startX = p.x;
            startY = p.y;
        }

        if (isClosePath)
        {
            graphics.drawLine(offsetX + startX, offsetY + startY, offsetX + firstX, offsetY +  firstY);
        }
    }
}
