module api.dm.kit.sprites2d.textures.vectors.shapes.varc;

import api.dm.kit.sprites2d.textures.vectors.shapes.vshape2d : VShape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class VArc : VShape
{
    double xCenter = 0;
    double yCenter = 0;
    double radius = 0;
    double fromAngleRad = 0;
    double toAngleRad = 2 * Math.PI;

    this(double radius, GraphicStyle style)
    {
        this(radius, style, radius * 2, radius * 2);
    }

    this(double radius, GraphicStyle style, double width, double height)
    {
        super(width, height, style);
        this.radius = radius;
    }

    override void createTextureContent()
    {
        auto ctx = canvas;

        ctx.translate(radius, radius);

        ctx.arc(xCenter, yCenter, radius - style.lineWidth / 2, fromAngleRad, toAngleRad);

        ctx.lineWidth = style.lineWidth;
        ctx.color = style.lineColor;

        ctx.stroke;
    }
}
