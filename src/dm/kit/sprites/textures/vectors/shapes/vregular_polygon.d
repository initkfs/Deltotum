module dm.kit.sprites.textures.vectors.shapes.vregular_polygon;

import dm.kit.sprites.textures.vectors.vshape : VShape;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
class VRegularPolygon : VShape
{
    protected
    {
        double cornerPadding = 0;
    }

    this(double width, double height, GraphicStyle style, double cornerPadding)
    {
        super(width, height, style);
        this.cornerPadding = cornerPadding;
    }

    override void createTextureContent()
    {
        import Math = dm.math;

        //TODO remove native api
        import dm.sys.cairo.libs;

        auto cr = cairoContext.getObject;
        cairo_set_antialias(cr, cairo_antialias_t.CAIRO_ANTIALIAS_GOOD);

        cairo_set_source_rgb(cr, style.fillColor.rNorm, style.fillColor.gNorm, style
                .fillColor.bNorm);
        const lineWidth = style.lineWidth;
        cairo_set_line_width(cr, lineWidth);

        const topLineEndX = width - cornerPadding;
        const topLineEndY = 0;

        cairo_move_to(cr, cornerPadding, 0);
        cairo_line_to(cr, topLineEndX, topLineEndY);

        const topRightCornerEndX = width;
        const topRightCornerEndY = cornerPadding;
        cairo_line_to(cr, topRightCornerEndX, topRightCornerEndY);

        const rightLineEndX = width;
        const rightLineEndY = height - cornerPadding;
        cairo_line_to(cr, rightLineEndX, rightLineEndY);

        const bottomRightCornerEndX = width - cornerPadding;
        const bottomRightCornerEndY = height;
        cairo_line_to(cr, bottomRightCornerEndX, bottomRightCornerEndY);

        const bottomLineEndX = cornerPadding;
        const bottomLineEndY = height;
        cairo_line_to(cr, bottomLineEndX, bottomLineEndY);

        const bottomLeftCornerEndX = 0;
        const bottomLeftCornerEndY = height - cornerPadding;
        cairo_line_to(cr, bottomLeftCornerEndX, bottomLeftCornerEndY);

        const leftLineEndX = 0;
        const leftLineEndY = cornerPadding;
        cairo_line_to(cr, leftLineEndX, leftLineEndY);

        const topLeftCornerEndX = cornerPadding;
        const topLeftCornerEndY = 0;
        cairo_line_to(cr, topLeftCornerEndX, topLeftCornerEndY);

        cairo_close_path(cr);

        if (style.isFill)
        {
            cairo_fill(cr);
        }
        else
        {
            cairo_stroke(cr);
        }

    }

    // override void drawContent()
    // {
    //     auto mainLineColor = style.lineColor;
    //     const lineWidth = style.lineWidth;

    //     const topLineStartX = x + cornerPadding;
    //     const topLineStartY = y;
    //     const topLineEndX = x + width - cornerPadding - lineWidth;
    //     const topLineEndY = y;
    //     //TODO y
    //     if (topClip.start.x != 0 || topClip.end.x != 0)
    //     {
    //         graphics.line(topLineStartX, topLineStartY, x + topClip.start.x, topLineEndY, mainLineColor);
    //         graphics.line(x + topClip.end.x, topLineStartY, topLineEndX, topLineEndY, mainLineColor);
    //     }
    //     else
    //     {
    //         graphics.line(topLineStartX, topLineStartY, topLineEndX, topLineEndY, mainLineColor);
    //     }

    //     const topRightCornerStartX = topLineEndX;
    //     const topRightCornerStartY = topLineEndY;
    //     const topRightCornerEndX = x + width - lineWidth;
    //     const topRightCornerEndY = y + cornerPadding;
    //     graphics.line(topRightCornerStartX, topRightCornerStartY, topRightCornerEndX, topRightCornerEndY, mainLineColor);

    //     const rightLineStartX = topRightCornerEndX;
    //     const rightLineStartY = topRightCornerEndY;
    //     const rightLineEndX = x + width - lineWidth;
    //     const rightLineEndY = y + height - cornerPadding - lineWidth;
    //     graphics.line(rightLineStartX, rightLineStartY, rightLineEndX, rightLineEndY, mainLineColor);

    //     const bottomRightCornerStartX = rightLineEndX;
    //     const bottomRightCornerStartY = rightLineEndY;
    //     const bottomRightCornerEndX = x + width - cornerPadding - lineWidth;
    //     const bottomRightCornerEndY = y + height - lineWidth;
    //     graphics.line(bottomRightCornerStartX, bottomRightCornerStartY, bottomRightCornerEndX, bottomRightCornerEndY, mainLineColor);

    //     const bottomLineStartX = bottomRightCornerEndX;
    //     const bottomLineStartY = bottomRightCornerEndY;
    //     const bottomLineEndX = x + cornerPadding;
    //     const bottomLineEndY = y + height - lineWidth;
    //     graphics.line(bottomLineStartX, bottomLineStartY, bottomLineEndX, bottomLineEndY, mainLineColor);

    //     const bottomLeftCornerStartX = bottomLineEndX;
    //     const bottomLeftCornerStartY = bottomLineEndY;
    //     const bottomLeftCornerEndX = x;
    //     const bottomLeftCornerEndY = y + height - cornerPadding - lineWidth;
    //     graphics.line(bottomLeftCornerStartX, bottomLeftCornerStartY, bottomLeftCornerEndX, bottomLeftCornerEndY, mainLineColor);

    //     const leftLineStartX = bottomLeftCornerEndX;
    //     const leftLineStartY = bottomLeftCornerEndY;
    //     const leftLineEndX = x;
    //     const leftLineEndY = y + cornerPadding;
    //     graphics.line(leftLineStartX, leftLineStartY, leftLineEndX, leftLineEndY, mainLineColor);

    //     const topLeftCornerStartX = leftLineEndX;
    //     const topLeftCornerStartY = leftLineEndY;
    //     const topLeftCornerEndX = topLineStartX;
    //     const topLeftCornerEndY = topLineStartY;
    //     graphics.line(topLeftCornerStartX, topLeftCornerStartY, topLeftCornerEndX, topLeftCornerEndY, mainLineColor);

    //     if (style.isFill)
    //     {
    //         fill;
    //     }
    // }

    // private void fill()
    // {
    //     import dm.math.vector2 : Vector2;

    //     import dm.kit.graphics.colors.rgba : RGBA;

    //     const fillColor = style.fillColor;

    //     graphics.fillRect(x + cornerPadding, y + style.lineWidth, width - cornerPadding * 2, height - style.lineWidth - 1, fillColor);

    //     //left side
    //     graphics.fillRect(x + style.lineWidth, y + cornerPadding, cornerPadding, height - cornerPadding * 2, fillColor);
    //     //right side
    //     graphics.fillRect(x + width - cornerPadding - style.lineWidth, y + cornerPadding, cornerPadding, height - cornerPadding * 2, fillColor);

    //     //left top corner
    //     graphics.fillTriangle(Vector2(x + style.lineWidth, y + cornerPadding), Vector2(x + cornerPadding, y + style
    //             .lineWidth), Vector2(
    //             x + cornerPadding, y + cornerPadding), fillColor);

    //     //left bottom corner
    //     graphics.fillTriangle(Vector2(x + style.lineWidth, y + height - cornerPadding - style.lineWidth * 2), Vector2(x + cornerPadding, y + height - cornerPadding - style
    //             .lineWidth * 2), Vector2(
    //             x + cornerPadding, y + height - style.lineWidth * 2), fillColor);

    //     //right top corner
    //     graphics.fillTriangle(Vector2(x + width - cornerPadding - style.lineWidth, y + style
    //             .lineWidth), Vector2(x + width - style.lineWidth * 2, y + cornerPadding), Vector2(
    //             x + width - cornerPadding - style.lineWidth, y + cornerPadding), fillColor);

    //     //right bottom corner
    //     graphics.fillTriangle(Vector2(x + width - cornerPadding - style.lineWidth, y + height - cornerPadding - style
    //             .lineWidth * 2), Vector2(x + width - style.lineWidth, y + height - cornerPadding - style.lineWidth * 2), Vector2(
    //             x + width - cornerPadding - style.lineWidth, y + height - style.lineWidth * 2), fillColor);
    // }
}
