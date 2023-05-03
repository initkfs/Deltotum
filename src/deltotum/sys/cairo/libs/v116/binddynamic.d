module deltotum.sys.cairo.libs.v116.binddynamic;

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
    alias c_cairo_image_surface_create = cairo_surface_t* function(cairo_format_t format, int width, int height);
    alias c_cairo_create = cairo_t* function(cairo_surface_t* target); 
}

__gshared
{
    c_cairo_image_surface_create cairo_image_surface_create;
    c_cairo_create cairo_create;
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
}
