module api.dm.kit.sprites2d.textures.vectors.shapes.vpoints_shape;

import api.dm.kit.sprites2d.textures.vectors.shapes.vshape2d : VShape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.math.geom2.vec2 : Vec2f;

import std.container.dlist : DList;

//TODO remove native api
import api.dm.lib.cairo;

/**
 * Authors: initkfs
 */
class VPointsShape : VShape
{
    void delegate() onDraw;

    // protected
    // {
    DList!Vec2f points;
    //}

    bool isFlipY;

    this(Vec2f[] points, float width, float height, GraphicStyle style, bool isClosePath = false, bool isDrawFromCenter = false)
    {
        super(width, height, style);

        this.points = points;
        this.isClosePath = isClosePath;
        this.isDrawFromCenter = isDrawFromCenter;

        this.points = DList!Vec2f(points);
    }

    size_t length()
    {
        import std.range : walkLength;

        return (points[]).walkLength;
    }

    void setDrawingContext()
    {
        auto ctx = cairoContext.getObject;

        if (isFlipY)
        {
            const cairo_matrix_t flipYAxisMatrix = {1, 0, 0, -1, 0, height};
            cairo_set_matrix(ctx, &flipYAxisMatrix);
        }

        if (isDrawFromCenter)
        {
            //TODO translateX?
            cairo_translate(ctx, width / 2, height / 2);
        }
        else
        {
            if (translateX > 0 || translateY > 0)
            {
                cairo_translate(ctx, translateX, translateY);
            }
        }
    }

    void setDrawingContextStyle()
    {
        auto ctx = cairoContext.getObject;

        cairo_set_line_width(ctx, style.lineWidth);
        color(style.lineColor);
    }

    void drawPoints()
    {
        assert(!points.empty);
        auto ctx = cairoContext.getObject;

        float startX = points.front.x, startY = points.front.y;
        cairo_move_to(ctx, startX, startY);

        import std.range : enumerate;

        //TODO first point
        foreach (i, p; (points[]).enumerate(1))
        {
            cairo_line_to(ctx, p.x, p.y);
            if (onDraw)
            {
                onDraw();
            }
        }

        if (isClosePath)
        {
            cairo_line_to(ctx, startX, startY);
            //TODO extract method
            if (onDraw)
            {
                onDraw();
            }
        }

        cairo_stroke(ctx);
    }

    override void createTextureContent()
    {
        if (length < 2)
        {
            return;
        }
        import Math = api.dm.math;

        setDrawingContext;
        setDrawingContextStyle;
        drawPoints;
    }
}
