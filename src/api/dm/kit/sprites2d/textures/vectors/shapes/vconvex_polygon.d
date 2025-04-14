module api.dm.kit.sprites2d.textures.vectors.shapes.vconvex_polygon;

import api.dm.kit.sprites2d.textures.vectors.shapes.vshape2d : VShape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
class VConvexPolygon : VShape
{
    protected
    {
        double cornerPadding = 0;
    }

    this(double width, double height, GraphicStyle style = GraphicStyle.simpleFill, double cornerPadding = 0)
    {
        super(width, height, style);
        this.cornerPadding = cornerPadding;
    }

    override void createTextureContent()
    {
        if (style.isFill)
        {
            canvas.color(style.fillColor);
        }

        const lineWidth = style.lineWidth;
        canvas.lineWidth(lineWidth);

        //TODO check corners + halfLine
        double halfLine = lineWidth / 2;

        const topLineEndX = width - cornerPadding - halfLine;
        const topLineEndY = halfLine;

        canvas.moveTo(halfLine + cornerPadding, halfLine);
        canvas.lineTo(topLineEndX, topLineEndY);

        const topRightCornerEndX = width - halfLine;
        const topRightCornerEndY = cornerPadding + halfLine;
        canvas.lineTo(topRightCornerEndX, topRightCornerEndY);

        const rightLineEndX = width - halfLine;
        const rightLineEndY = height - cornerPadding - halfLine;
        canvas.lineTo(rightLineEndX, rightLineEndY);

        const bottomRightCornerEndX = width - cornerPadding - halfLine;
        const bottomRightCornerEndY = height - halfLine;
        canvas.lineTo(bottomRightCornerEndX, bottomRightCornerEndY);

        const bottomLineEndX = cornerPadding + halfLine;
        const bottomLineEndY = height - halfLine;
        canvas.lineTo(bottomLineEndX, bottomLineEndY);

        const bottomLeftCornerEndX = halfLine;
        const bottomLeftCornerEndY = height - cornerPadding - halfLine;
        canvas.lineTo(bottomLeftCornerEndX, bottomLeftCornerEndY);

        const leftLineEndX = halfLine;
        const leftLineEndY = cornerPadding + halfLine;
        canvas.lineTo(leftLineEndX, leftLineEndY);

        const topLeftCornerEndX = cornerPadding + halfLine;
        const topLeftCornerEndY = halfLine;
        canvas.lineTo(topLeftCornerEndX, topLeftCornerEndY);

        canvas.closePath;

        if(style.isFill){
            canvas.color = style.fillColor;
            canvas.fill;
        }

        canvas.color(style.lineColor);
        canvas.stroke;
    }
}
