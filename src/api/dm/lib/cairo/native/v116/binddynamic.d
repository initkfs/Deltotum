module api.dm.lib.cairo.native.v116.binddynamic;

/**
 * Authors: initkfs
 */
version (Cairo116)  : import api.dm.lib.cairo.native.v116.types;
import api.core.utils.libs.dynamics.dynamic_loader : DynamicLoader;

extern (C) @nogc nothrow
{
    cairo_t* function(cairo_surface_t* target) cairo_create;
    cairo_surface_t* function(cairo_format_t format, int width, int height) cairo_image_surface_create;
    cairo_surface_t* function(
        ubyte* data, cairo_format_t format, int width, int height, int stride) cairo_image_surface_create_for_data;
    void function(cairo_surface_t* surface) cairo_surface_destroy;
    void function(cairo_t* cr) cairo_destroy;

    void function(cairo_t* cr, double width) cairo_set_line_width;
    void function(cairo_t* cr, double red, double green, double blue) cairo_set_source_rgb;
    void function(cairo_t* cr, double red, double green, double blue, double alpha) cairo_set_source_rgba;

    void function(cairo_t* cr) cairo_stroke;
    void function(cairo_t* cr) cairo_stroke_preserve;

    void function(cairo_t* cr, double x, double y) cairo_move_to;
    void function(cairo_t* cr, double x, double y) cairo_line_to;

    void function(cairo_t* cr) cairo_fill;
    void function(cairo_t* cr) cairo_paint;
    void function(cairo_t* cr) cairo_fill_preserve;

    void function(cairo_t* cr, double tx, double ty) cairo_translate;
    void function(cairo_t* cr, double sx, double sy) cairo_scale;
    void function(cairo_t* cr, double angleRad) cairo_rotate;

    void function(
        cairo_t* cr,
        double xc,
        double yc,
        double radius,
        double angle1,
        double angle2) cairo_arc;

    void function(
        cairo_t* cr,
        double xc,
        double yc,
        double radius,
        double angle1,
        double angle2) cairo_arc_negative;

    void function(cairo_t* cr,
        double x, double y,
        double width, double height) cairo_rectangle;

    void function(cairo_t* cr, const cairo_matrix_t* matrix) cairo_set_matrix;

    void function(cairo_t* cr) cairo_new_path;
    void function(cairo_t* cr) cairo_close_path;
    void function(cairo_t* cr, cairo_antialias_t antialias) cairo_set_antialias;
    void function(cairo_t* cr,
        double* x,
        double* y) cairo_user_to_device;
    void function(cairo_t* cr,
        double* x,
        double* y) cairo_device_to_user;

    void function(cairo_t* cr, const double* dashes, int num_dashes, double offset) cairo_set_dash;

    void function(cairo_t* cr, cairo_line_join_t line_join) cairo_set_line_join;
    void function(cairo_t* cr, cairo_line_cap_t line_cap) cairo_set_line_cap;

    void function(cairo_t* cr) cairo_save;
    void function(cairo_t* cr) cairo_restore;

    cairo_bool_t function(cairo_t* cr, double x, double y) cairo_in_stroke;
    cairo_bool_t function(cairo_t* cr, double x, double y) cairo_in_clip;
    cairo_bool_t function(cairo_t* cr, double x, double y) cairo_in_fill;

    void function(cairo_t* cr, double x1, double y1, double x2, double y2, double x3, double y3) cairo_curve_to;

    void function(cairo_t* cr) cairo_clip;

    void function(cairo_pattern_t*) cairo_pattern_destroy;
    cairo_pattern_t* function(double x0, double y0, double x1, double y1) cairo_pattern_create_linear;
    cairo_pattern_t* function(double cx0,
        double cy0,
        double radius0,
        double cx1,
        double cy1,
        double radius1) cairo_pattern_create_radial;
    void function(
        cairo_pattern_t* pattern,
        double offset0to1,
        double red0to1,
        double green0to1,
        double blue0to1,
        double alpha0to1) cairo_pattern_add_color_stop_rgba;
    void function(cairo_t* cr, cairo_pattern_t* source) cairo_set_source;
}

class CairoLib : DynamicLoader
{
    override void bindAll()
    {
        bind(&cairo_image_surface_create, "cairo_image_surface_create");
        bind(&cairo_create, "cairo_create");
        bind(&cairo_image_surface_create_for_data, "cairo_image_surface_create_for_data");
        bind(&cairo_surface_destroy, "cairo_surface_destroy");
        bind(&cairo_destroy, "cairo_destroy");

        bind(&cairo_set_line_width, "cairo_set_line_width");
        bind(&cairo_set_source_rgb, "cairo_set_source_rgb");
        bind(&cairo_set_source_rgba, "cairo_set_source_rgba");

        bind(&cairo_stroke, "cairo_stroke");
        bind(&cairo_stroke_preserve, "cairo_stroke_preserve");

        bind(&cairo_move_to, "cairo_move_to");
        bind(&cairo_line_to, "cairo_line_to");

        bind(&cairo_paint, "cairo_paint");
        bind(&cairo_fill, "cairo_fill");
        bind(&cairo_fill_preserve, "cairo_fill_preserve");

        bind(&cairo_translate, "cairo_translate");
        bind(&cairo_scale, "cairo_scale");
        bind(&cairo_rotate, "cairo_rotate");

        bind(&cairo_arc, "cairo_arc");
        bind(&cairo_arc_negative, "cairo_arc_negative");

        bind(&cairo_rectangle, "cairo_rectangle");

        bind(&cairo_set_matrix, "cairo_set_matrix");
        bind(&cairo_new_path, "cairo_new_path");
        bind(&cairo_close_path, "cairo_close_path");
        bind(&cairo_set_antialias, "cairo_set_antialias");
        bind(&cairo_user_to_device, "cairo_user_to_device");
        bind(&cairo_device_to_user, "cairo_device_to_user");
        bind(&cairo_set_dash, "cairo_set_dash");
        bind(&cairo_set_line_cap, "cairo_set_line_cap");
        bind(&cairo_set_line_join, "cairo_set_line_join");

        bind(&cairo_save, "cairo_save");
        bind(&cairo_restore, "cairo_restore");

        bind(&cairo_in_stroke, "cairo_in_stroke");
        bind(&cairo_in_clip, "cairo_in_clip");
        bind(&cairo_in_fill, "cairo_in_fill");

        bind(&cairo_curve_to, "cairo_curve_to");
        bind(&cairo_clip, "cairo_clip");

        bind(&cairo_pattern_destroy, "cairo_pattern_destroy");
        bind(&cairo_pattern_create_linear, "cairo_pattern_create_linear");
        bind(&cairo_pattern_create_radial, "cairo_pattern_create_radial");
        bind(&cairo_pattern_add_color_stop_rgba, "cairo_pattern_add_color_stop_rgba");
        bind(&cairo_set_source, "cairo_set_source");
    }

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

    override int libVersion()
    {
        return 116;
    }

}
