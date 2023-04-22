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

    override void createTextureContent()
    {
        auto mainLineColor = style.lineColor;
        const lineWidth = style.lineWidth;

        const topLineStartX = cornerPadding;
        const topLineStartY = 0;
        const topLineEndX = width - cornerPadding - lineWidth;
        const topLineEndY = 0;
        graphics.drawLine(topLineStartX, topLineStartY, topLineEndX, topLineEndY, mainLineColor);

        const topRightCornerStartX = topLineEndX;
        const topRightCornerStartY = topLineEndY;
        const topRightCornerEndX = width - lineWidth;
        const topRightCornerEndY = cornerPadding;
        graphics.drawLine(topRightCornerStartX, topRightCornerStartY, topRightCornerEndX, topRightCornerEndY, mainLineColor);

        const rightLineStartX = topRightCornerEndX;
        const rightLineStartY = topRightCornerEndY;
        const rightLineEndX = width - lineWidth;
        const rightLineEndY = height - cornerPadding - lineWidth;
        graphics.drawLine(rightLineStartX, rightLineStartY, rightLineEndX, rightLineEndY, mainLineColor);

        const bottomRightCornerStartX = rightLineEndX;
        const bottomRightCornerStartY = rightLineEndY;
        const bottomRightCornerEndX = width - cornerPadding - lineWidth;
        const bottomRightCornerEndY = height - lineWidth;
        graphics.drawLine(bottomRightCornerStartX, bottomRightCornerStartY, bottomRightCornerEndX, bottomRightCornerEndY, mainLineColor);

        const bottomLineStartX = bottomRightCornerEndX;
        const bottomLineStartY = bottomRightCornerEndY;
        const bottomLineEndX = cornerPadding;
        const bottomLineEndY = height - lineWidth;
        graphics.drawLine(bottomLineStartX, bottomLineStartY, bottomLineEndX, bottomLineEndY, mainLineColor);

        const bottomLeftCornerStartX = bottomLineEndX;
        const bottomLeftCornerStartY = bottomLineEndY;
        const bottomLeftCornerEndX = 0;
        const bottomLeftCornerEndY = height - cornerPadding - lineWidth;
        graphics.drawLine(bottomLeftCornerStartX, bottomLeftCornerStartY, bottomLeftCornerEndX, bottomLeftCornerEndY, mainLineColor);

        const leftLineStartX = bottomLeftCornerEndX;
        const leftLineStartY = bottomLeftCornerEndY;
        const leftLineEndX = 0;
        const leftLineEndY = cornerPadding;
        graphics.drawLine(leftLineStartX, leftLineStartY, leftLineEndX, leftLineEndY, mainLineColor);

        const topLeftCornerStartX = leftLineEndX;
        const topLeftCornerStartY = leftLineEndY;
        const topLeftCornerEndX = topLineStartX;
        const topLeftCornerEndY = topLineStartY;
        graphics.drawLine(topLeftCornerStartX, topLeftCornerStartY, topLeftCornerEndX, topLeftCornerEndY, mainLineColor);

        if(style.isFill){
            fill;
        }
    }

    private void fill(){
        import deltotum.math.vector2d: Vector2d;
        graphics.drawRect(cornerPadding, 0, width - cornerPadding * 2, height, style);

        //left side
        graphics.drawRect(0, cornerPadding, cornerPadding, height - cornerPadding * 2, style);
        //right side
        graphics.drawRect(width - cornerPadding - style.lineWidth, cornerPadding, cornerPadding, height - cornerPadding * 2, style);

        //left top corner
        graphics.drawTriangle(Vector2d(0, cornerPadding), Vector2d(cornerPadding, 0), Vector2d(cornerPadding, cornerPadding), style.fillColor);

        //left bottom corner
        graphics.drawTriangle(Vector2d(0, height - cornerPadding - 1), Vector2d(cornerPadding, height - cornerPadding), Vector2d(cornerPadding, height - 1), style.fillColor);
        
        //right top corner
        graphics.drawTriangle(Vector2d(width - cornerPadding - style.lineWidth, 0), Vector2d(width- 1, cornerPadding), Vector2d(width - cornerPadding, cornerPadding), style.fillColor);

        //right bottom corner
        graphics.drawTriangle(Vector2d(width - cornerPadding - style.lineWidth, height - cornerPadding - 1), Vector2d(width - 1, height - cornerPadding - 1), Vector2d(width - cornerPadding - style.lineWidth, height - 1), style.fillColor);
    }
}
