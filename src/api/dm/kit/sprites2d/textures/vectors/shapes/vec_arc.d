module api.dm.kit.sprites2d.textures.vectors.shapes.vec_arc;

import api.dm.kit.sprites2d.textures.vectors.shapes.vec_shape : VecShape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class VecArc : VecShape
{
    float xCenter = 0;
    float yCenter = 0;
    float radius = 0;
    float fromAngleRad = 0;
    float toAngleRad = 2 * Math.PI;

    this(float radius, GraphicStyle style)
    {
        this(radius, style, radius * 2, radius * 2);
    }

    this(float radius, GraphicStyle style, float width, float height)
    {
        super(width, height, style);
        this.radius = radius;
    }

    override void createContent()
    {
        auto ctx = canvas;

        ctx.translate(_width / 2, _height / 2);

        const arcRadius = radius - style.lineWidth / 2 - 1;

        ctx.arc(xCenter, yCenter, arcRadius, fromAngleRad, toAngleRad);

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
