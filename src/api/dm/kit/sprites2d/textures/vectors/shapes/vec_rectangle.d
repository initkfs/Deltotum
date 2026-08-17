module api.dm.kit.sprites2d.textures.vectors.shapes.vec_rectangle;

import api.dm.kit.sprites2d.textures.vectors.shapes.vec_shape : VecShape;
import api.dm.kit.graphics.styles.gstyle : GStyle;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class VecRectangle : VecShape
{
    this(float width = 50, float height = 50, GStyle style = GStyle.simple) 
    {
        super(width, height, style);
    }

    override void createContent()
    {
        import Math = api.dm.math;

        auto ctx = canvas;

        if (!isInnerStroke)
        {
            ctx.rect(0, 0, width, height);
        }
        else
        {
            auto halfLine = style.lineWidth / 2;
            ctx.rect(halfLine, halfLine, width - halfLine, height - halfLine);
        }

        if (style.isFill)
        {
            ctx.color = style.fillColor;
            ctx.fill;
        }

        ctx.lineWidth = style.lineWidth;
        ctx.color = style.lineColor;
        ctx.stroke;
    }
}
