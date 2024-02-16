module dm.sys.cairo.libs.v116.binddynamic;

/**
 * Authors: initkfs
 */
version (Cairo116)  : import dm.sys.cairo.libs.v116.types;
import dm.sys.base.sys_lib : SysLib;

extern (C) @nogc nothrow
{
    alias c_cairo_create = cairo_t* function(cairo_surface_t* target);

    alias c_cairo_image_surface_create = cairo_surface_t* function(cairo_format_t format, int width, int height);

    alias c_cairo_image_surface_create_for_data = cairo_surface_t* function(
        ubyte* data, cairo_format_t format, int width, int height, int stride);

    alias c_cairo_surface_destroy = void function(cairo_surface_t* surface);
    alias c_cairo_destroy = void function(cairo_t* cr);

    alias c_cairo_set_line_width = void function(cairo_t* cr, double width);
    alias c_cairo_set_source_rgb = void function(cairo_t* cr, double red, double green, double blue);
    alias c_cairo_set_source_rgba = void function(cairo_t* cr, double red, double green, double blue, double alpha);

    alias c_cairo_move_to = void function(cairo_t* cr, double x, double y);
    alias c_cairo_line_to = void function(cairo_t* cr, double x, double y);

    alias c_cairo_stroke = void function(cairo_t* cr);
    alias c_cairo_stroke_preserve = void function(cairo_t* cr);

    alias c_cairo_fill = void function(cairo_t* cr);
    alias c_cairo_fill_preserve = void function(cairo_t* cr);

    alias c_cairo_translate = void function(cairo_t* cr, double tx, double ty);
    alias c_cairo_scale = void function(cairo_t* cr, double sx, double sy);

    alias c_cairo_arc = void function(
        cairo_t* cr,
        double xc,
        double yc,
        double radius,
        double angle1,
        double angle2);
    alias c_cairo_arc_negative = void function(
        cairo_t* cr,
        double xc,
        double yc,
        double radius,
        double angle1,
        double angle2);

    alias c_cairo_rectangle = void function(cairo_t* cr,
        double x, double y,
        double width, double height);

    alias c_cairo_set_matrix = void function(cairo_t* cr, const cairo_matrix_t* matrix);

    alias c_cairo_close_path = void function(cairo_t* cr);
    alias c_cairo_set_antialias = void function(cairo_t* cr, cairo_antialias_t antialias);
    alias c_cairo_user_to_device = void function(cairo_t* cr,
        double* x,
        double* y);
    alias c_cairo_device_to_user = void function(cairo_t* cr,
        double* x,
        double* y);
}

__gshared
{
    c_cairo_image_surface_create cairo_image_surface_create;
    c_cairo_create cairo_create;
    c_cairo_image_surface_create_for_data cairo_image_surface_create_for_data;
    c_cairo_surface_destroy cairo_surface_destroy;
    c_cairo_destroy cairo_destroy;

    c_cairo_set_line_width cairo_set_line_width;
    c_cairo_set_source_rgb cairo_set_source_rgb;
    c_cairo_set_source_rgba cairo_set_source_rgba;

    c_cairo_stroke cairo_stroke;
    c_cairo_stroke_preserve cairo_stroke_preserve;

    c_cairo_move_to cairo_move_to;
    c_cairo_line_to cairo_line_to;

    c_cairo_fill cairo_fill;
    c_cairo_fill_preserve cairo_fill_preserve;

    c_cairo_translate cairo_translate;
    c_cairo_scale cairo_scale;

    c_cairo_arc cairo_arc;
    c_cairo_arc_negative cairo_arc_negative;

    c_cairo_rectangle cairo_rectangle;

    c_cairo_set_matrix cairo_set_matrix;

    c_cairo_close_path cairo_close_path;
    c_cairo_set_antialias cairo_set_antialias;
    c_cairo_user_to_device cairo_user_to_device;
    c_cairo_device_to_user cairo_device_to_user;
}

class CairoLib : SysLib
{
    version (Windows)
    {
        const(char)[][2] paths = ["libcairo-2.dll", "cairo.dll"];
    }
    else version (OSX)
    {
        const(char)[][1] paths = ["libcairo.dylib"];
    }
    else version (Posix)
    {
        const(char)[][2] paths = ["libcairo.so.2", "libcairo.so"];
    }
    else
    {
        const(char)[0][0] paths;
    }

    override const(char[][]) libPaths()
    {
        return paths;
    }

    override void bindSymbols()
    {
        bind(cast(void**)&cairo_image_surface_create, "cairo_image_surface_create");
        bind(cast(void**)&cairo_create, "cairo_create");
        bind(cast(void**)&cairo_image_surface_create_for_data, "cairo_image_surface_create_for_data");
        bind(cast(void**)&cairo_surface_destroy, "cairo_surface_destroy");
        bind(cast(void**)&cairo_destroy, "cairo_destroy");

        bind(cast(void**)&cairo_set_line_width, "cairo_set_line_width");
        bind(cast(void**)&cairo_set_source_rgb, "cairo_set_source_rgb");
        bind(cast(void**)&cairo_set_source_rgba, "cairo_set_source_rgba");

        bind(cast(void**)&cairo_stroke, "cairo_stroke");
        bind(cast(void**)&cairo_stroke_preserve, "cairo_stroke_preserve");

        bind(cast(void**)&cairo_move_to, "cairo_move_to");
        bind(cast(void**)&cairo_line_to, "cairo_line_to");

        bind(cast(void**)&cairo_fill, "cairo_fill");
        bind(cast(void**)&cairo_fill_preserve, "cairo_fill_preserve");

        bind(cast(void**)&cairo_translate, "cairo_translate");
        bind(cast(void**)&cairo_scale, "cairo_scale");

        bind(cast(void**)&cairo_arc, "cairo_arc");
        bind(cast(void**)&cairo_arc_negative, "cairo_arc_negative");

        bind(cast(void**)&cairo_rectangle, "cairo_rectangle");

        bind(cast(void**)&cairo_set_matrix, "cairo_set_matrix");
        bind(cast(void**)&cairo_close_path, "cairo_close_path");
        bind(cast(void**)&cairo_set_antialias, "cairo_set_antialias");
        bind(cast(void**)&cairo_user_to_device, "cairo_user_to_device");
        bind(cast(void**)&cairo_device_to_user, "cairo_device_to_user");
    }

    override protected int needVersion()
    {
        return 116;
    }

}
