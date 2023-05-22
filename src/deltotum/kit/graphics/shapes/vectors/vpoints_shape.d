module deltotum.kit.graphics.shapes.vectors.vpoints_shape;

import deltotum.kit.graphics.shapes.vectors.vshape : VShape;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.math.vector2d : Vector2d;

/**
 * Authors: initkfs
 */
class VPointsShape : VShape
{
    private
    {
        Vector2d[] points;
    }
    this(Vector2d[] points, double width, double height, GraphicStyle style)
    {
        super(width, height, style);
        this.points = points;
    }

    override void createTextureContent()
    {
        if (points.length < 2)
        {
            return;
        }
        import Math = deltotum.math;

        //TODO remove native api
        import deltotum.sys.cairo.libs;

        auto ctx = cairoContext.getObject;

        cairo_translate(ctx, width / 2, height / 2);

        cairo_set_line_width(ctx, style.lineWidth);
        auto color = style.lineColor;
        cairo_set_source_rgb(ctx, color.rNorm, color.gNorm, color.bNorm);

        double startX = points[0].x, startY = points[0].y;
        cairo_move_to(ctx, startX, startY);
        foreach (p; points[1 .. $])
        {
            cairo_line_to(ctx, p.x, p.y);
        }

        cairo_stroke(ctx);
    }
}
