module api.dm.kit.sprites2d.textures.vectors.canvases.vector_canvas;

import api.dm.kit.graphics.canvases.graphic_canvas : GraphicCanvas, GStop;
import api.dm.lib.cairo.cairo_context : CairoContext;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.geom2.vec2 : Vec2f;

//TODO remove native api
import api.dm.lib.cairo;

/**
 * Authors: initkfs
 */
class VectorCanvas : GraphicCanvas
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
        cairo_set_source_rgba(cr, rgba.rNorm, rgba.gNorm, rgba.bNorm, rgba.a);
        if (lastColor != rgba)
        {
            lastColor = rgba;
            isChangeColor = true;
        }
    }

    RGBA color() => lastColor;

    void lineEnd(GraphicCanvas.LineEnd end)
    {
        final switch (end) with (GraphicCanvas.LineEnd)
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

    void lineJoin(GraphicCanvas.LineJoin joinType)
    {
        final switch (joinType) with (GraphicCanvas.LineJoin)
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

    void lineWidth(float width)
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

    void translate(float x, float y)
    {
        cairo_translate(cr, x, y);
    }

    void scale(float sx, float sy)
    {
        cairo_scale(cr, sx, sy);
    }

    void rotateRad(float angleRad)
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

    void moveTo(float x, float y)
    {
        cairo_move_to(cr, x, y);
    }

    void moveTo(Vec2f pos)
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

    void lineTo(float endX, float endY)
    {
        cairo_line_to(cr, endX, endY);
    }

    void lineTo(Vec2f pos)
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

    void rect(float x, float y, float width, float height)
    {
        cairo_rectangle(cr, x, y, width, height);
    }

    void fillRect(float x, float y, float width, float height)
    {
        rect(x, y, width, height);
        fill;
    }

    void strokeRect(float x, float y, float width, float height)
    {
        rect(x, y, width, height);
        stroke;
    }

    void clearRect(float x, float y, float width, float height)
    {
        color(RGBA.transparent);
        scope (exit)
        {
            restoreColor;
        }
        cairo_rectangle(cr, x, y, width, height);
        fill;
    }

    bool isPointInPath(float x, float y)
    {
        if (cairo_in_stroke(cr, x, y) || cairo_in_fill(cr, x, y))
        {
            return true;
        }

        return false;
    }

    void fillTriangle(float x1, float y1, float x2, float y2, float x3, float y3)
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

    void clip()
    {
        cairo_clip(cr);
    }

    void arc(float xc, float yc, float radius, float angle1Rad, float angle2Rad)
    {
        cairo_arc(cr, xc, yc, radius, angle1Rad, angle2Rad);
    }

    void bezierCurveTo(float x1, float y1, float x2, float y2, float x3, float y3)
    {
        cairo_curve_to(cr, x1, y1, x2, y2, x3, y3);
    }

    void linearGradient(float x0, float y0, float x1, float y1, GStop[] stopPoints, void delegate() onPattern)
    {
        linearGradient(Vec2f(x0, y0), Vec2f(x1, y1), stopPoints, onPattern);
    }

    void linearGradient(Vec2f start, Vec2f end, GStop[] stopPoints, void delegate() onPattern)
    {
        cairo_pattern_t* pattern = cairo_pattern_create_linear(start.x, start.y, end.x, end.y);

        foreach (stopPoint; stopPoints)
        {
            auto color = stopPoint.color;
            cairo_pattern_add_color_stop_rgba(pattern, stopPoint.offset, color.rNorm, color.gNorm, color.bNorm, color
                    .a);
        }

        cairo_set_source(cr, pattern);

        assert(onPattern);
        onPattern();

        scope (exit)
        {
            cairo_pattern_destroy(pattern);
        }
    }

    void radialGradient(Vec2f innerCenter, float innerRadius, Vec2f outerCenter, float outerRadius, GStop[] stopPoints, void delegate() onPattern)
    {

        cairo_pattern_t* pattern = cairo_pattern_create_radial(innerCenter.x, innerCenter.y, innerRadius, outerCenter
                .x, outerCenter.y, outerRadius);

        foreach (stopPoint; stopPoints)
        {
            auto color = stopPoint.color;
            cairo_pattern_add_color_stop_rgba(pattern, stopPoint.offset, color.rNorm, color.gNorm, color.bNorm, color
                    .a);
        }

        cairo_set_source(cr, pattern);

        assert(onPattern);
        onPattern();

        scope (exit)
        {
            cairo_pattern_destroy(pattern);
        }
    }

    void text(string text)
    {
        import std.utf : toUTFz;

        cairo_text_path(cr, text.toUTFz!(const(char)*));
    }

    void strokeText(string str, float x, float y)
    {
        moveTo(x, y);
        text(str);
        stroke;
    }

    void fillText(string str, float x, float y)
    {
        moveTo(x, y);
        text(str);
        fill;
    }

    void fontFace(string name)
    {
        import std.string : toStringz;

        cairo_select_font_face(cr, name.toStringz, cairo_font_slant_t.CAIRO_FONT_SLANT_NORMAL, cairo_font_weight_t
                .CAIRO_FONT_WEIGHT_NORMAL);
    }

    void fontSize(double size)
    {
        cairo_set_font_size(cr, size);
    }

    void miterLimit(double size)
    {
        cairo_set_miter_limit(cr, size);
    }
}
