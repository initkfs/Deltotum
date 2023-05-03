module deltotum.sys.cairo.libs.v116.binddynamic;

/**
 * Authors: initkfs
 */
version (BindCairoStatic)
{
    static assert(0, "Cairo static linking not supported yet.");
}
else version = BindCairoDynamic;

version (Cairo116)
{
    version (BindCairoDynamic) version = Cairo116Dynamic;
}

version (Cairo116Dynamic)  : import deltotum.sys.cairo.libs.config;
import deltotum.sys.cairo.libs.v116.types;

import Loader = bindbc.loader;

extern (C) @nogc nothrow
{
    alias c_cairo_create = cairo_t * function(cairo_surface_t * target);

    alias c_cairo_image_surface_create = cairo_surface_t * function(cairo_format_t format, int width, int height);

    alias c_cairo_image_surface_create_for_data = cairo_surface_t * function(
        ubyte * data, cairo_format_t format, int width, int height, int stride);

    alias c_cairo_surface_destroy = void function(cairo_surface_t * surface);
    alias c_cairo_destroy = void function(cairo_t * cr);

    alias c_cairo_set_line_width = void function(cairo_t * cr, double width);
    alias c_cairo_set_source_rgb = void function(cairo_t * cr, double red, double green, double blue);
    alias c_cairo_set_source_rgba = void function(cairo_t * cr, double red, double green, double blue, double alpha);

    alias c_cairo_stroke = void function(cairo_t * cr);
    alias c_cairo_stroke_preserve = void function(cairo_t * cr);

    alias c_cairo_fill = void function(cairo_t * cr);
    alias c_cairo_fill_preserve = void function(cairo_t * cr);

    alias c_cairo_translate = void function(cairo_t * cr, double tx, double ty);
    alias c_cairo_scale = void function(cairo_t * cr, double sx, double sy);

    alias c_cairo_arc = void function(
        cairo_t * cr,
        double xc,
        double yc,
        double radius,
        double angle1,
        double angle2);
    alias c_cairo_arc_negative = void function(
        cairo_t * cr,
        double xc,
        double yc,
        double radius,
        double angle1,
        double angle2);

    alias c_cairo_rectangle  = void function(cairo_t *cr,
		 double x, double y,
		 double width, double height);
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

    c_cairo_fill cairo_fill;
    c_cairo_fill_preserve cairo_fill_preserve;

    c_cairo_translate cairo_translate;
    c_cairo_scale cairo_scale;

    c_cairo_arc cairo_arc;
    c_cairo_arc_negative cairo_arc_negative;

    c_cairo_rectangle cairo_rectangle;

}

private
{
    Loader.SharedLib lib;
}

void unload() @nogc nothrow
{
    if (lib != Loader.invalidHandle)
    {
        Loader.unload(lib);
    }
}

bool isLoaded() @nogc nothrow @safe
{
    return lib != Loader.invalidHandle;
}

CairoSupport load() @nogc nothrow
{
    version (Windows)
    {
        const(char)[][2] libPaths = ["libcairo-2.dll", "cairo.dll"];
    }
    else version (OSX)
    {
        const(char)[][1] libPaths = ["libcairo.dylib"];
    }
    else version (Posix)
    {
        const(char)[][2] libPaths = ["libcairo.so.2", "libcairo.so"];
    }
    else
        static assert(0, "Cairo support for Cairo 1.16 is not implemented on this platform.");

    CairoSupport result;
    foreach (path; libPaths)
    {
        result = load(path.ptr);
        if (result != CairoSupport.noLibrary)
        {
            break;
        }
    }

    return result;
}

const(Loader.ErrorInfo)[] errors() @nogc nothrow
{
    return Loader.errors;
}

CairoSupport load(const(char)* libPath) @nogc nothrow
{
    lib = Loader.load(libPath);
    if (lib == Loader.invalidHandle)
    {
        return CairoSupport.noLibrary;
    }

    Loader.resetErrors;

    bindSymbols;

    if (Loader.errorCount() != 0)
        return CairoSupport.badLibrary;

    return CairoSupport.cairo116;
}

private void bindSymbols() @nogc nothrow
{
    Loader.bindSymbol(lib, cast(void**)&cairo_image_surface_create, "cairo_image_surface_create");
    Loader.bindSymbol(lib, cast(void**)&cairo_create, "cairo_create");
    Loader.bindSymbol(lib, cast(void**)&cairo_image_surface_create_for_data, "cairo_image_surface_create_for_data");
    Loader.bindSymbol(lib, cast(void**)&cairo_surface_destroy, "cairo_surface_destroy");
    Loader.bindSymbol(lib, cast(void**)&cairo_destroy, "cairo_destroy");

    Loader.bindSymbol(lib, cast(void**)&cairo_set_line_width, "cairo_set_line_width");
    Loader.bindSymbol(lib, cast(void**)&cairo_set_source_rgb, "cairo_set_source_rgb");
     Loader.bindSymbol(lib, cast(void**)&cairo_set_source_rgba, "cairo_set_source_rgba");

    Loader.bindSymbol(lib, cast(void**)&cairo_stroke, "cairo_stroke");
    Loader.bindSymbol(lib, cast(void**)&cairo_stroke_preserve, "cairo_stroke_preserve");

    Loader.bindSymbol(lib, cast(void**)&cairo_fill, "cairo_fill");
    Loader.bindSymbol(lib, cast(void**)&cairo_fill_preserve, "cairo_fill_preserve");

    Loader.bindSymbol(lib, cast(void**)&cairo_translate, "cairo_translate");
    Loader.bindSymbol(lib, cast(void**)&cairo_scale, "cairo_scale");

    Loader.bindSymbol(lib, cast(void**)&cairo_arc, "cairo_arc");
    Loader.bindSymbol(lib, cast(void**)&cairo_arc_negative, "cairo_arc_negative");

     Loader.bindSymbol(lib, cast(void**)&cairo_rectangle, "cairo_rectangle");
}
