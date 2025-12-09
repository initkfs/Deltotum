module api.dm.kit.sprites2d.shapes.convex_polygon;

import api.dm.kit.sprites2d.shapes.shape2d : Shape2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.math.geom2.line2 : Line2f;

/**
 * Authors: initkfs
 */
class ConvexPolygon : Shape2d
{
    float cornerPadding;

    //TODO other sides  
    Line2f topClip;

    this(float width, float height, GraphicStyle style, float cornerPadding)
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
            graphic.line(topLineStartX, topLineStartY, x + topClip.start.x, topLineEndY, mainLineColor);
            graphic.line(x + topClip.end.x, topLineStartY, topLineEndX, topLineEndY, mainLineColor);
        }
        else
        {
            graphic.line(topLineStartX, topLineStartY, topLineEndX, topLineEndY, mainLineColor);
        }

        const topRightCornerStartX = topLineEndX;
        const topRightCornerStartY = topLineEndY;
        const topRightCornerEndX = x + width - lineWidth;
        const topRightCornerEndY = y + cornerPadding;
        graphic.line(topRightCornerStartX, topRightCornerStartY, topRightCornerEndX, topRightCornerEndY, mainLineColor);

        const rightLineStartX = topRightCornerEndX;
        const rightLineStartY = topRightCornerEndY;
        const rightLineEndX = x + width - lineWidth;
        const rightLineEndY = y + height - cornerPadding - lineWidth;
        graphic.line(rightLineStartX, rightLineStartY, rightLineEndX, rightLineEndY, mainLineColor);

        const bottomRightCornerStartX = rightLineEndX;
        const bottomRightCornerStartY = rightLineEndY;
        const bottomRightCornerEndX = x + width - cornerPadding - lineWidth;
        const bottomRightCornerEndY = y + height - lineWidth;
        graphic.line(bottomRightCornerStartX, bottomRightCornerStartY, bottomRightCornerEndX, bottomRightCornerEndY, mainLineColor);

        const bottomLineStartX = bottomRightCornerEndX;
        const bottomLineStartY = bottomRightCornerEndY;
        const bottomLineEndX = x + cornerPadding;
        const bottomLineEndY = y + height - lineWidth;
        graphic.line(bottomLineStartX, bottomLineStartY, bottomLineEndX, bottomLineEndY, mainLineColor);

        const bottomLeftCornerStartX = bottomLineEndX;
        const bottomLeftCornerStartY = bottomLineEndY;
        const bottomLeftCornerEndX = x;
        const bottomLeftCornerEndY = y + height - cornerPadding - lineWidth;
        graphic.line(bottomLeftCornerStartX, bottomLeftCornerStartY, bottomLeftCornerEndX, bottomLeftCornerEndY, mainLineColor);

        const leftLineStartX = bottomLeftCornerEndX;
        const leftLineStartY = bottomLeftCornerEndY;
        const leftLineEndX = x;
        const leftLineEndY = y + cornerPadding;
        graphic.line(leftLineStartX, leftLineStartY, leftLineEndX, leftLineEndY, mainLineColor);

        const topLeftCornerStartX = leftLineEndX;
        const topLeftCornerStartY = leftLineEndY;
        const topLeftCornerEndX = topLineStartX;
        const topLeftCornerEndY = topLineStartY;
        graphic.line(topLeftCornerStartX, topLeftCornerStartY, topLeftCornerEndX, topLeftCornerEndY, mainLineColor);

        if (style.isFill)
        {
            fill;
        }
    }

    private void fill()
    {
        import api.math.geom2.vec2 : Vec2f;

        import api.dm.kit.graphics.colors.rgba : RGBA;

        const fillColor = style.fillColor;

        graphic.fillRect(x + cornerPadding, y + style.lineWidth, width - cornerPadding * 2, height - style.lineWidth - 1, fillColor);

        //left side
        graphic.fillRect(x + style.lineWidth, y + cornerPadding, cornerPadding, height - cornerPadding * 2, fillColor);
        //right side
        graphic.fillRect(x + width - cornerPadding - style.lineWidth, y + cornerPadding, cornerPadding, height - cornerPadding * 2, fillColor);

        //left top corner
        graphic.fillTriangle(Vec2f(x + style.lineWidth, y + cornerPadding), Vec2f(x + cornerPadding, y + style
                .lineWidth), Vec2f(
                x + cornerPadding, y + cornerPadding), fillColor);

        //left bottom corner
        graphic.fillTriangle(Vec2f(x + style.lineWidth, y + height - cornerPadding - style.lineWidth * 2),Vec2f(x + cornerPadding, y + height - cornerPadding - style
                .lineWidth * 2), Vec2f(
                x + cornerPadding, y + height - style.lineWidth * 2), fillColor);

        //right top corner
        graphic.fillTriangle(Vec2f(x + width - cornerPadding - style.lineWidth, y + style
                .lineWidth), Vec2f(x + width - style.lineWidth * 2, y + cornerPadding), Vec2f(
                x + width - cornerPadding - style.lineWidth, y + cornerPadding), fillColor);

        //right bottom corner
        graphic.fillTriangle(Vec2f(x + width - cornerPadding - style.lineWidth, y + height - cornerPadding - style.lineWidth * 2), Vec2f(x + width - style.lineWidth, y + height - cornerPadding - style.lineWidth * 2), Vec2f(
                x + width - cornerPadding - style.lineWidth, y + height - style.lineWidth * 2), fillColor);
    }
}
