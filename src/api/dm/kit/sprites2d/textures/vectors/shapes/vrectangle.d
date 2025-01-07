module api.dm.kit.sprites2d.textures.vectors.shapes.vrectangle;

import api.dm.kit.sprites2d.textures.vectors.shapes.vshape2d : VShape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class VRectangle : VShape
{
    this(double width = 50, double height = 50, GraphicStyle style)
    {
        super(width, height, style);
    }

    override void createTextureContent()
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
            ctx.fillPreserve;
        }

        ctx.lineWidth = style.lineWidth;
        ctx.color = style.lineColor;
        ctx.stroke;
    }
}
