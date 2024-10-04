module api.dm.kit.sprites.textures.vectors.contexts.vector_graphics_context;

import api.dm.kit.graphics.contexts.graphics_context : GraphicsContext;
import api.dm.sys.cairo.cairo_context : CairoContext;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.vec2 : Vec2d;

//TODO remove native api
import api.dm.sys.cairo.libs;

/**
 * Authors: initkfs
 */
class VectorGraphicsContext : GraphicsContext
{
    protected
    {
        CairoContext context;
        cairo_t* cr;

        bool isChangeColor;
        RGBA lastColor;
    }

    this(CairoContext context)
    {
        if (!context)
        {
            throw new Exception("Cairo context must not be null");
        }
        this.context = context;
        this.cr = context.getObject;
        assert(cr);

        cairo_set_antialias(cr, cairo_antialias_t.CAIRO_ANTIALIAS_GOOD);
    }

    void color(RGBA rgba)
    {
        cairo_set_source_rgb(cr, rgba.rNorm, rgba.gNorm, rgba.bNorm);
        if (lastColor != rgba)
        {
            lastColor = rgba;
            isChangeColor = true;
        }
    }

    void lineEnd(GraphicsContext.LineEnd end)
    {
        final switch (end) with (GraphicsContext.LineEnd)
        {
            case butt:
                cairo_set_line_cap(cr, cairo_line_cap_t.CAIRO_LINE_CAP_BUTT);
                break;
            case round:
                cairo_set_line_cap(cr, cairo_line_cap_t.CAIRO_LINE_CAP_ROUND);
                break;
            case square:
                cairo_set_line_cap(cr, cairo_line_cap_t.CAIRO_LINE_CAP_SQUARE);
                break;
        }
    }

    void lineJoin(GraphicsContext.LineJoin joinType)
    {
        final switch (joinType) with (GraphicsContext.LineJoin)
        {
            case miter:
                cairo_set_line_join(cr, cairo_line_join_t.CAIRO_LINE_JOIN_MITER);
                break;
            case round:
                cairo_set_line_join(cr, cairo_line_join_t.CAIRO_LINE_JOIN_ROUND);
                break;
            case bevel:
                cairo_set_line_join(cr, cairo_line_join_t.CAIRO_LINE_JOIN_BEVEL);
                break;
        }
    }

    void lineWidth(double width)
    {
        cairo_set_line_width(cr, width);
    }

    void restoreColor()
    {
        if (isChangeColor)
        {
            color(lastColor);
        }
    }

    void translate(double x, double y)
    {
        cairo_translate(cr, x, y);
    }

    void scale(double sx, double sy)
    {
        cairo_scale(cr, sx, sy);
    }

    void rotateRad(double angleRad)
    {
        cairo_rotate(cr, angleRad);
    }

    void save()
    {
        cairo_save(cr);
    }

    void restore()
    {
        cairo_restore(cr);
    }

    void moveTo(double x, double y)
    {
        cairo_move_to(cr, x, y);
    }

    void moveTo(Vec2d pos)
    {
        moveTo(pos.x, pos.y);
    }

    void clear(RGBA newColor)
    {
        //TODO prev color
        color(newColor);
        cairo_paint(cr);
    }

    void reset()
    {
        cairo_move_to(cr, 0, 0);
    }

    void lineTo(double endX, double endY)
    {
        cairo_line_to(cr, endX, endY);
    }

    void lineTo(Vec2d pos)
    {
        lineTo(pos.x, pos.y);
    }

    void stroke()
    {
        cairo_stroke(cr);
    }

    void strokePreserve()
    {
        cairo_stroke_preserve(cr);
    }

    void fill()
    {
        cairo_fill(cr);
    }

    void fillPreserve()
    {
        cairo_fill_preserve(cr);
    }

    void rect(double x, double y, double width, double height)
    {
        cairo_rectangle(cr, x, y, width, height);
    }

    void fillRect(double x, double y, double width, double height)
    {
        rect(x, y, width, height);
        fill;
    }

    void clearRect(double x, double y, double width, double height)
    {
        color(RGBA.transparent);
        scope (exit)
        {
            restoreColor;
        }
        cairo_rectangle(cr, x, y, width, height);
        fill;
    }

    bool isPointInPath(double x, double y)
    {
        if (cairo_in_stroke(cr, x, y) || cairo_in_fill(cr, x, y))
        {
            return true;
        }

        return false;
    }

    void fillTriangle(double x1, double y1, double x2, double y2, double x3, double y3)
    {
        moveTo(x1, y1);
        lineTo(x2, y2);
        lineTo(x3, y3);
        lineTo(x1, y1);
        fill;
    }

    void beginPath()
    {
        cairo_new_path(cr);
    }

    void closePath()
    {
        cairo_close_path(cr);
    }

    void clip(){
        cairo_clip(cr);
    }

    void arc(double xc, double yc, double radius, double angle1Rad, double angle2Rad)
    {
        cairo_arc(cr, xc, yc, radius, angle1Rad, angle2Rad);
    }

    void bezierCurveTo(double x1, double y1, double x2, double y2, double x3, double y3){
        cairo_curve_to(cr, x1, y1, x2, y2, x3, y3);
    }
}
