module api.dm.kit.sprites2d.textures.vectors.shapes.vec_convex_poly;

import api.dm.kit.sprites2d.textures.vectors.shapes.vec_shape : VecShape;
import api.dm.kit.graphics.styles.gstyle : GStyle;

/**
 * Authors: initkfs
 */
class VecConvexPoly : VecShape
{
    protected
    {
        float cornerPadding = 0;
    }

    this(float width, float height, GStyle style = GStyle.simpleFill, float cornerPadding = 0)
    {
        super(width, height, style);
        this.cornerPadding = cornerPadding;
    }

    override void createContent()
    {
        const lineWidth = style.lineWidth;
        canvas.lineWidth(lineWidth);

        import api.dm.kit.graphics.canvases.graphic_canvas : GraphicCanvas;

        // canvas.lineEnd = GraphicCanvas.LineEnd.round;
        // canvas.lineJoin = GraphicCanvas.LineJoin.round;

        //TODO check corners + halfLine
        float halfLine = lineWidth / 2 + 0.5;

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
            canvas.fillPreserve;
        }
        
        canvas.color(style.lineColor);
        canvas.stroke;
    }
}
