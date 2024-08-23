module api.dm.kit.sprites.shapes.regular_polygon;

import api.dm.kit.sprites.shapes.shape : Shape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.math.line2d : Line2d;

/**
 * Authors: initkfs
 */
class RegularPolygon : Shape
{
    double cornerPadding;

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
            graphics.line(topLineStartX, topLineStartY, x + topClip.start.x, topLineEndY, mainLineColor);
            graphics.line(x + topClip.end.x, topLineStartY, topLineEndX, topLineEndY, mainLineColor);
        }
        else
        {
            graphics.line(topLineStartX, topLineStartY, topLineEndX, topLineEndY, mainLineColor);
        }

        const topRightCornerStartX = topLineEndX;
        const topRightCornerStartY = topLineEndY;
        const topRightCornerEndX = x + width - lineWidth;
        const topRightCornerEndY = y + cornerPadding;
        graphics.line(topRightCornerStartX, topRightCornerStartY, topRightCornerEndX, topRightCornerEndY, mainLineColor);

        const rightLineStartX = topRightCornerEndX;
        const rightLineStartY = topRightCornerEndY;
        const rightLineEndX = x + width - lineWidth;
        const rightLineEndY = y + height - cornerPadding - lineWidth;
        graphics.line(rightLineStartX, rightLineStartY, rightLineEndX, rightLineEndY, mainLineColor);

        const bottomRightCornerStartX = rightLineEndX;
        const bottomRightCornerStartY = rightLineEndY;
        const bottomRightCornerEndX = x + width - cornerPadding - lineWidth;
        const bottomRightCornerEndY = y + height - lineWidth;
        graphics.line(bottomRightCornerStartX, bottomRightCornerStartY, bottomRightCornerEndX, bottomRightCornerEndY, mainLineColor);

        const bottomLineStartX = bottomRightCornerEndX;
        const bottomLineStartY = bottomRightCornerEndY;
        const bottomLineEndX = x + cornerPadding;
        const bottomLineEndY = y + height - lineWidth;
        graphics.line(bottomLineStartX, bottomLineStartY, bottomLineEndX, bottomLineEndY, mainLineColor);

        const bottomLeftCornerStartX = bottomLineEndX;
        const bottomLeftCornerStartY = bottomLineEndY;
        const bottomLeftCornerEndX = x;
        const bottomLeftCornerEndY = y + height - cornerPadding - lineWidth;
        graphics.line(bottomLeftCornerStartX, bottomLeftCornerStartY, bottomLeftCornerEndX, bottomLeftCornerEndY, mainLineColor);

        const leftLineStartX = bottomLeftCornerEndX;
        const leftLineStartY = bottomLeftCornerEndY;
        const leftLineEndX = x;
        const leftLineEndY = y + cornerPadding;
        graphics.line(leftLineStartX, leftLineStartY, leftLineEndX, leftLineEndY, mainLineColor);

        const topLeftCornerStartX = leftLineEndX;
        const topLeftCornerStartY = leftLineEndY;
        const topLeftCornerEndX = topLineStartX;
        const topLeftCornerEndY = topLineStartY;
        graphics.line(topLeftCornerStartX, topLeftCornerStartY, topLeftCornerEndX, topLeftCornerEndY, mainLineColor);

        if (style.isFill)
        {
            fill;
        }
    }

    private void fill()
    {
        import api.dm.math.vector2 : Vector2;

        import api.dm.kit.graphics.colors.rgba : RGBA;

        const fillColor = style.fillColor;

        graphics.fillRect(x + cornerPadding, y + style.lineWidth, width - cornerPadding * 2, height - style.lineWidth - 1, fillColor);

        //left side
        graphics.fillRect(x + style.lineWidth, y + cornerPadding, cornerPadding, height - cornerPadding * 2, fillColor);
        //right side
        graphics.fillRect(x + width - cornerPadding - style.lineWidth, y + cornerPadding, cornerPadding, height - cornerPadding * 2, fillColor);

        //left top corner
        graphics.fillTriangle(Vector2(x + style.lineWidth, y + cornerPadding), Vector2(x + cornerPadding, y + style
                .lineWidth), Vector2(
                x + cornerPadding, y + cornerPadding), fillColor);

        //left bottom corner
        graphics.fillTriangle(Vector2(x + style.lineWidth, y + height - cornerPadding - style.lineWidth * 2),Vector2(x + cornerPadding, y + height - cornerPadding - style
                .lineWidth * 2), Vector2(
                x + cornerPadding, y + height - style.lineWidth * 2), fillColor);

        //right top corner
        graphics.fillTriangle(Vector2(x + width - cornerPadding - style.lineWidth, y + style
                .lineWidth), Vector2(x + width - style.lineWidth * 2, y + cornerPadding), Vector2(
                x + width - cornerPadding - style.lineWidth, y + cornerPadding), fillColor);

        //right bottom corner
        graphics.fillTriangle(Vector2(x + width - cornerPadding - style.lineWidth, y + height - cornerPadding - style.lineWidth * 2), Vector2(x + width - style.lineWidth, y + height - cornerPadding - style.lineWidth * 2), Vector2(
                x + width - cornerPadding - style.lineWidth, y + height - style.lineWidth * 2), fillColor);
    }
}
