module api.dm.kit.sprites.textures.vectors.shapes.vregular_polygon;

import api.dm.kit.sprites.textures.vectors.shapes.vshape : VShape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
class VRegularPolygon : VShape
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

        const topLineEndX = width - cornerPadding;
        const topLineEndY = 0;

        canvas.moveTo(cornerPadding, 0);
        canvas.lineTo(topLineEndX, topLineEndY);

        const topRightCornerEndX = width;
        const topRightCornerEndY = cornerPadding;
        canvas.lineTo(topRightCornerEndX, topRightCornerEndY);

        const rightLineEndX = width;
        const rightLineEndY = height - cornerPadding;
        canvas.lineTo(rightLineEndX, rightLineEndY);

        const bottomRightCornerEndX = width - cornerPadding;
        const bottomRightCornerEndY = height;
        canvas.lineTo(bottomRightCornerEndX, bottomRightCornerEndY);

        const bottomLineEndX = cornerPadding;
        const bottomLineEndY = height;
        canvas.lineTo(bottomLineEndX, bottomLineEndY);

        const bottomLeftCornerEndX = 0;
        const bottomLeftCornerEndY = height - cornerPadding;
        canvas.lineTo(bottomLeftCornerEndX, bottomLeftCornerEndY);

        const leftLineEndX = 0;
        const leftLineEndY = cornerPadding;
        canvas.lineTo(leftLineEndX, leftLineEndY);

        const topLeftCornerEndX = cornerPadding;
        const topLeftCornerEndY = 0;
        canvas.lineTo(topLeftCornerEndX, topLeftCornerEndY);

        canvas.closePath;

        if(style.isFill){
            canvas.fillPreserve;
        }

        canvas.color(style.lineColor);
        canvas.stroke;
    }
}
