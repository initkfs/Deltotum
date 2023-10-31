module deltotum.kit.sprites.shapes.regular_polygon;

import deltotum.kit.sprites.shapes.shape : Shape;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.math.line2d : Line2d;

/**
 * Authors: initkfs
 */
class RegularPolygon : Shape
{
    const double cornerPadding;

    //TODO other sides  
    Line2d topClip;

    this(double width, double height, GraphicStyle style, double cornerPadding)
    {
        super(width, height, style);
        this.cornerPadding = cornerPadding;
    }

    override void drawContent()
    {
        auto mainLineColor = style.lineColor;
        const lineWidth = style.lineWidth;

        const topLineStartX = x + cornerPadding;
        const topLineStartY = y;
        const topLineEndX = x + width - cornerPadding - lineWidth;
        const topLineEndY = y;
        //TODO y
        if (topClip.start.x != 0 || topClip.end.x != 0)
        {
            graphics.drawLine(topLineStartX, topLineStartY, x + topClip.start.x, topLineEndY, mainLineColor);
            graphics.drawLine(x + topClip.end.x, topLineStartY, topLineEndX, topLineEndY, mainLineColor);
        }
        else
        {
            graphics.drawLine(topLineStartX, topLineStartY, topLineEndX, topLineEndY, mainLineColor);
        }

        const topRightCornerStartX = topLineEndX;
        const topRightCornerStartY = topLineEndY;
        const topRightCornerEndX = x + width - lineWidth;
        const topRightCornerEndY = y + cornerPadding;
        graphics.drawLine(topRightCornerStartX, topRightCornerStartY, topRightCornerEndX, topRightCornerEndY, mainLineColor);

        const rightLineStartX = topRightCornerEndX;
        const rightLineStartY = topRightCornerEndY;
        const rightLineEndX = x + width - lineWidth;
        const rightLineEndY = y + height - cornerPadding - lineWidth;
        graphics.drawLine(rightLineStartX, rightLineStartY, rightLineEndX, rightLineEndY, mainLineColor);

        const bottomRightCornerStartX = rightLineEndX;
        const bottomRightCornerStartY = rightLineEndY;
        const bottomRightCornerEndX = x + width - cornerPadding - lineWidth;
        const bottomRightCornerEndY = y + height - lineWidth;
        graphics.drawLine(bottomRightCornerStartX, bottomRightCornerStartY, bottomRightCornerEndX, bottomRightCornerEndY, mainLineColor);

        const bottomLineStartX = bottomRightCornerEndX;
        const bottomLineStartY = bottomRightCornerEndY;
        const bottomLineEndX = x + cornerPadding;
        const bottomLineEndY = y + height - lineWidth;
        graphics.drawLine(bottomLineStartX, bottomLineStartY, bottomLineEndX, bottomLineEndY, mainLineColor);

        const bottomLeftCornerStartX = bottomLineEndX;
        const bottomLeftCornerStartY = bottomLineEndY;
        const bottomLeftCornerEndX = x;
        const bottomLeftCornerEndY = y + height - cornerPadding - lineWidth;
        graphics.drawLine(bottomLeftCornerStartX, bottomLeftCornerStartY, bottomLeftCornerEndX, bottomLeftCornerEndY, mainLineColor);

        const leftLineStartX = bottomLeftCornerEndX;
        const leftLineStartY = bottomLeftCornerEndY;
        const leftLineEndX = x;
        const leftLineEndY = y + cornerPadding;
        graphics.drawLine(leftLineStartX, leftLineStartY, leftLineEndX, leftLineEndY, mainLineColor);

        const topLeftCornerStartX = leftLineEndX;
        const topLeftCornerStartY = leftLineEndY;
        const topLeftCornerEndX = topLineStartX;
        const topLeftCornerEndY = topLineStartY;
        graphics.drawLine(topLeftCornerStartX, topLeftCornerStartY, topLeftCornerEndX, topLeftCornerEndY, mainLineColor);

        if (style.isFill)
        {
            fill;
        }
    }

    private void fill()
    {
        import deltotum.math.vector2d : Vector2d;

        enum sizeDt = 2.0;

        graphics.fillRect(x + cornerPadding, y + style.lineWidth, width - cornerPadding * 2, height - style.lineWidth - 1, style
                .fillColor);

        //left side
        graphics.fillRect(x + style.lineWidth, y + cornerPadding, cornerPadding, height - cornerPadding * 2, style
                .fillColor);
        //right side
        graphics.fillRect(x + width - cornerPadding - style.lineWidth, y + cornerPadding, cornerPadding, height - cornerPadding * 2, style
                .fillColor);

        //left top corner
        graphics.drawTriangle(Vector2d(x + style.lineWidth * 2, y + cornerPadding - style.lineWidth), Vector2d(x + cornerPadding - style.lineWidth, y + style
                .lineWidth * 2), Vector2d(
                x + cornerPadding - style.lineWidth, y + cornerPadding - style.lineWidth), style
                .fillColor);

        //left bottom corner
        graphics.drawTriangle(Vector2d(x + style.lineWidth * 2, y + height - cornerPadding), Vector2d(x + cornerPadding - style.lineWidth, y + height - cornerPadding), Vector2d(
                x + cornerPadding - style.lineWidth, y + height - style.lineWidth * 3), style
                .fillColor);

        //right top corner
        graphics.drawTriangle(Vector2d(x + width - cornerPadding, y + style.lineWidth * 2), Vector2d(x + width - style.lineWidth * 3, y + cornerPadding - style
                .lineWidth), Vector2d(
                x + width - cornerPadding, y + cornerPadding - style.lineWidth), style.fillColor);

        //right bottom corner
        graphics.drawTriangle(Vector2d(x + width - cornerPadding, y + height - cornerPadding), Vector2d(x + width - style.lineWidth * 3, y + height - cornerPadding), Vector2d(
                x + width - cornerPadding, y + height - style.lineWidth * 3), style.fillColor);
    }
}
