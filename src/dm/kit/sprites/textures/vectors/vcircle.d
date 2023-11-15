module dm.kit.sprites.textures.vectors.vcircle;

import dm.kit.sprites.textures.vectors.vshape: VShape;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
class VCircle : VShape
{
    double radius = 0;

    this(double radius, GraphicStyle style)
    {
        super(radius * 2, radius * 2, style);
        this.radius = radius;
    }

    override void createTextureContent()
    {
        import Math = dm.math;

        //TODO remove native api
        import dm.sys.cairo.libs;

        auto cr = cairoContext.getObject;

        cairo_translate(cr, width / 2, height / 2);

        cairo_set_source_rgb(cr, style.fillColor.rNorm, style.fillColor.gNorm, style
                .fillColor.bNorm);
        cairo_arc(cr, 0, 0, radius - style.lineWidth / 2, 0, 2 * Math.PI);
        cairo_fill_preserve(cr);

        cairo_set_line_width(cr, style.lineWidth);
        cairo_set_source_rgb(cr, style.lineColor.rNorm, style.lineColor.gNorm, style
                .lineColor.bNorm);

        cairo_stroke(cr);
    }
}
