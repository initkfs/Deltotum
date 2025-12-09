module api.dm.kit.sprites2d.textures.vectors.shapes.vtriangle;

import api.dm.kit.sprites2d.textures.vectors.shapes.vshape2d : VShape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class VTriangle : VShape
{
    float xCenter = 0;
    float yCenter = 0;

    this(float width = 50, float height = 50, GraphicStyle style)
    {
        super(width, height, style);
    }

    override void createTextureContent()
    {
        import Math = api.dm.math;

        //TODO remove native api
        import api.dm.lib.cairo;

        auto cr = cairoContext.getObject;

        cairo_set_source_rgb(cr, style.fillColor.rNorm, style.fillColor.gNorm, style
                    .fillColor.bNorm);

        //https://math.stackexchange.com/questions/3952129/calculate-bounds-of-the-inner-rectangle-of-the-polygon-based-on-its-constant-bo/3952746
        //https://stackoverflow.com/questions/68825416/how-to-set-correct-path-for-triangle-along-with-stroke-in-cashaplayer

        const lineHalfWidth = style.lineWidth / 2;
        const topPadding = lineHalfWidth / Math.sin(Math.atan(0.5));
        const bottomPadding = lineHalfWidth;
        const leftRightPadding = (topPadding + bottomPadding) / 2;

        cairo_move_to(cr, leftRightPadding, height - bottomPadding);
        cairo_line_to(cr, width / 2, topPadding);
        cairo_line_to(cr, width - leftRightPadding, height - bottomPadding);
        cairo_line_to(cr, leftRightPadding, height - bottomPadding);
        cairo_close_path(cr);
        
        if(style.isFill){
            cairo_fill_preserve(cr);
        }

        cairo_set_line_width(cr, style.lineWidth);
        cairo_set_source_rgb(cr, style.lineColor.rNorm, style.lineColor.gNorm, style
                .lineColor.bNorm);

        cairo_stroke(cr);
    }
}
