module dm.kit.sprites.textures.vectors.contexts.vector_graphics_context;

import dm.kit.graphics.contexts.graphics_context : GraphicsContext;
import dm.sys.cairo.cairo_context : CairoContext;
import dm.kit.graphics.colors.rgba : RGBA;

//TODO remove native api
import dm.sys.cairo.libs;

/**
 * Authors: initkfs
 */
class VectorGraphicsContext : GraphicsContext
{
    protected
    {
        CairoContext context;
        cairo_t* cr;
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

    void setColor(RGBA rgba)
    {
        cairo_set_source_rgb(cr, rgba.rNorm, rgba.gNorm, rgba.bNorm);
    }

    void setLineWidth(double width)
    {
        cairo_set_line_width(cr, width);
    }

    void restoreColor()
    {

    }

    void moveTo(double x, double y)
    {
        cairo_move_to(cr, x, y);
    }

    void reset()
    {
        cairo_move_to(cr, 0, 0);
    }

    void lineTo(double endX, double endY)
    {
        cairo_line_to(cr, endX, endY);
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

    void fillRect(double x, double y, double width, double height)
    {
        cairo_rectangle(cr, x, y, width, height);
        fill;
    }

    void fillTriangle(double x1, double y1, double x2, double y2, double x3, double y3)
    {
        moveTo(x1, y1);
        lineTo(x2, y2);
        lineTo(x3, y3);
        lineTo(x1, y1);
        fill;
    }

    void closePath()
    {
        cairo_close_path(cr);
    }
}
