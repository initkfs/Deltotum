module dm.kit.sprites.textures.vectors.shapes.vregular_polygon;

import dm.kit.sprites.textures.vectors.vshape : VShape;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;

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
        import Math = dm.math;

        //TODO remove native api
        import dm.sys.cairo.libs;

        auto cr = cairoContext.getObject;
        cairo_set_antialias(cr, cairo_antialias_t.CAIRO_ANTIALIAS_GOOD);

        cairo_set_source_rgb(cr, style.fillColor.rNorm, style.fillColor.gNorm, style
                .fillColor.bNorm);
        const lineWidth = style.lineWidth;
        cairo_set_line_width(cr, lineWidth);

        const topLineEndX = width - cornerPadding;
        const topLineEndY = 0;

        cairo_move_to(cr, cornerPadding, 0);
        cairo_line_to(cr, topLineEndX, topLineEndY);

        const topRightCornerEndX = width;
        const topRightCornerEndY = cornerPadding;
        cairo_line_to(cr, topRightCornerEndX, topRightCornerEndY);

        const rightLineEndX = width;
        const rightLineEndY = height - cornerPadding;
        cairo_line_to(cr, rightLineEndX, rightLineEndY);

        const bottomRightCornerEndX = width - cornerPadding;
        const bottomRightCornerEndY = height;
        cairo_line_to(cr, bottomRightCornerEndX, bottomRightCornerEndY);

        const bottomLineEndX = cornerPadding;
        const bottomLineEndY = height;
        cairo_line_to(cr, bottomLineEndX, bottomLineEndY);

        const bottomLeftCornerEndX = 0;
        const bottomLeftCornerEndY = height - cornerPadding;
        cairo_line_to(cr, bottomLeftCornerEndX, bottomLeftCornerEndY);

        const leftLineEndX = 0;
        const leftLineEndY = cornerPadding;
        cairo_line_to(cr, leftLineEndX, leftLineEndY);

        const topLeftCornerEndX = cornerPadding;
        const topLeftCornerEndY = 0;
        cairo_line_to(cr, topLeftCornerEndX, topLeftCornerEndY);

        cairo_close_path(cr);

        cairo_stroke_preserve(cr);
        
        if (style.isFill)
        {
            cairo_fill(cr);
        }
    }
}
