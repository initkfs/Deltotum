module dm.kit.sprites.textures.vectors.shapes.varc;

import dm.kit.sprites.textures.vectors.shapes.vshape : VShape;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;

import Math = dm.math;

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
        import Math = dm.math;

        //TODO remove native api
        import dm.sys.cairo.libs;

        auto cr = cairoContext.getObject;

        cairo_translate(cr, width / 2, height / 2);

        if (style.isFill)
        {
            cairo_set_source_rgba(cr, style.fillColor.rNorm, style.fillColor.gNorm, style
                    .fillColor.bNorm, style.fillColor.a);
        }

        cairo_arc(cr, xCenter, yCenter, radius - style.lineWidth / 2, fromAngleRad, toAngleRad);
        
        if(style.isFill){
            cairo_fill_preserve(cr);
        }

        cairo_set_line_width(cr, style.lineWidth);
        cairo_set_source_rgba(cr, style.lineColor.rNorm, style.lineColor.gNorm, style
                .lineColor.bNorm, style.lineColor.a);

        cairo_stroke(cr);
    }
}
