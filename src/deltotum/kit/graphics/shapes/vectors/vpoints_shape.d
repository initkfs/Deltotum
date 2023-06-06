module deltotum.kit.graphics.shapes.vectors.vpoints_shape;

import deltotum.kit.graphics.shapes.vectors.vshape : VShape;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.math.vector2d : Vector2d;

//TODO remove native api
import deltotum.sys.cairo.libs;

/**
 * Authors: initkfs
 */
class VPointsShape : VShape
{
    bool isClosePath;
    bool isDrawFromCenter;

    private
    {
        Vector2d[] points;
    }
    this(Vector2d[] points, double width, double height, GraphicStyle style, bool isClosePath = false, bool isDrawFromCenter = false)
    {
        super(width, height, style);
        
        this.points = points;
        this.isClosePath = isClosePath;
        this.isDrawFromCenter = isDrawFromCenter;
    }

    void setDrawingContext()
    {
        auto ctx = cairoContext.getObject;

        const cairo_matrix_t flipYAxisMatrix = {1, 0, 0, -1, 0, height};
        cairo_set_matrix(ctx, &flipYAxisMatrix);

        if(isDrawFromCenter){
            cairo_translate(ctx, width / 2, height / 2);
        }
    }

    void setDrawingContextStyle()
    {
        auto ctx = cairoContext.getObject;

        cairo_set_line_width(ctx, style.lineWidth);
        auto color = style.lineColor;
        cairo_set_source_rgb(ctx, color.rNorm, color.gNorm, color.bNorm);
    }

    void drawPoints()
    {
        auto ctx = cairoContext.getObject;

        double startX = points[0].x, startY = points[0].y;
        cairo_move_to(ctx, startX, startY);
        foreach (p; points[1 .. $])
        {
            cairo_line_to(ctx, p.x, p.y);
        }

        if (isClosePath)
        {
            cairo_line_to(ctx, startX, startY);
        }

        cairo_stroke(ctx);
    }

    override void createTextureContent()
    {
        if (points.length < 2)
        {
            return;
        }
        import Math = deltotum.math;

        setDrawingContext;
        setDrawingContextStyle;
        drawPoints;
    }
}
