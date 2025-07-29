module api.dm.lib.cairo.cairo_surface;

import api.dm.lib.cairo.base.cairo_object_wrapper : CairoObjectWrapper;

import api.dm.lib.cairo.native;

/**
 * Authors: initkfs
 */
class CairoSurface : CairoObjectWrapper!cairo_surface_t
{
    this(cairo_surface_t* surf)
    {
        assert(surf);
        super(surf);
    }

    this(ubyte* data, cairo_format_t format, int width, int height, int stride)
    {
        ptr = cairo_image_surface_create_for_data(data, format, width, height, stride);
        if (!ptr)
        {
            throw new Exception("Cairo surface error.");
        }
    }

    this(cairo_write_func_t write_func, void* closure, double width_in_points, double height_in_points)
    {
        ptr = cairo_svg_surface_create_for_stream(write_func, closure, width_in_points, height_in_points);
        if (!ptr)
        {
            throw new Exception("Cairo surface error.");
        }
    }

    void finish()
    {
        cairo_surface_finish(ptr);
    }

    void flush()
    {
        cairo_surface_flush(ptr);
    }

    override bool disposePtr()
    {
        if (ptr)
        {
            cairo_surface_destroy(ptr);
            return true;
        }

        return false;
    }
}
