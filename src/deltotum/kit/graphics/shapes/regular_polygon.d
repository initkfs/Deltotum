module deltotum.kit.graphics.shapes.regular_polygon;

import deltotum.kit.graphics.shapes.shape;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
class RegularPolygon : Shape
{
    const double cornerPadding;

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
        graphics.drawLine(topLineStartX, topLineStartY, topLineEndX, topLineEndY, mainLineColor);

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

        graphics.drawRect(x + cornerPadding, y, width - cornerPadding * 2, height, style);

        //left side
        graphics.drawRect(x, cornerPadding, y + cornerPadding, height - cornerPadding * 2, style);
        //right side
        graphics.drawRect(x + width - cornerPadding - style.lineWidth, y + cornerPadding, cornerPadding, height - cornerPadding * 2, style);

        //left top corner
        graphics.drawTriangle(Vector2d(x, y + cornerPadding), Vector2d(x + cornerPadding, y), Vector2d(
                x + cornerPadding, y + cornerPadding), style.fillColor);

        //left bottom corner
        graphics.drawTriangle(Vector2d(x, y + height - cornerPadding - 1), Vector2d(x + cornerPadding, y + height - cornerPadding), Vector2d(
                x + cornerPadding, y + height - 1), style.fillColor);

        //right top corner
        graphics.drawTriangle(Vector2d(x + width - cornerPadding - style.lineWidth, y), Vector2d(x + width - 1, y + cornerPadding), Vector2d(
                x + width - cornerPadding, y + cornerPadding), style.fillColor);

        //right bottom corner
        graphics.drawTriangle(Vector2d(x + width - cornerPadding - style.lineWidth, y + height - cornerPadding - 1), Vector2d(x + width - 1, y + height - cornerPadding - 1), Vector2d(
                x + width - cornerPadding - style.lineWidth, y + height - 1), style.fillColor);
    }
}
