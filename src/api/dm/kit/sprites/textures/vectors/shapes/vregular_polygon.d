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

    this(double width, double height, GraphicStyle style, double cornerPadding)
    {
        super(width, height, style);
        this.cornerPadding = cornerPadding;
    }

    override void createTextureContent()
    {
        if (style.isFill)
        {
            gContext.setColor(style.fillColor);
        }

        const lineWidth = style.lineWidth;
        gContext.setLineWidth(lineWidth);

        const topLineEndX = width - cornerPadding;
        const topLineEndY = 0;

        gContext.moveTo(cornerPadding, 0);
        gContext.lineTo(topLineEndX, topLineEndY);

        const topRightCornerEndX = width;
        const topRightCornerEndY = cornerPadding;
        gContext.lineTo(topRightCornerEndX, topRightCornerEndY);

        const rightLineEndX = width;
        const rightLineEndY = height - cornerPadding;
        gContext.lineTo(rightLineEndX, rightLineEndY);

        const bottomRightCornerEndX = width - cornerPadding;
        const bottomRightCornerEndY = height;
        gContext.lineTo(bottomRightCornerEndX, bottomRightCornerEndY);

        const bottomLineEndX = cornerPadding;
        const bottomLineEndY = height;
        gContext.lineTo(bottomLineEndX, bottomLineEndY);

        const bottomLeftCornerEndX = 0;
        const bottomLeftCornerEndY = height - cornerPadding;
        gContext.lineTo(bottomLeftCornerEndX, bottomLeftCornerEndY);

        const leftLineEndX = 0;
        const leftLineEndY = cornerPadding;
        gContext.lineTo(leftLineEndX, leftLineEndY);

        const topLeftCornerEndX = cornerPadding;
        const topLeftCornerEndY = 0;
        gContext.lineTo(topLeftCornerEndX, topLeftCornerEndY);

        gContext.closePath;

        if(style.isFill){
            gContext.fillPreserve;
        }

        gContext.setColor(style.lineColor);
        gContext.stroke;
    }
}
