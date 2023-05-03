module deltotum.sys.cairo.cairo_surface;

import deltotum.sys.cairo.base.cairo_object_wrapper : CairoObjectWrapper;
import deltotum.sys.cairo.libs;

/**
 * Authors: initkfs
 */
class CairoSurface : CairoObjectWrapper!cairo_surface_t
{

    this(ubyte* data, int width, int height, int stride, cairo_format_t format = cairo_format_t
            .CAIRO_FORMAT_RGB24)
    {
        ptr = cairo_image_surface_create_for_data(data, format, width, height, stride);
        if (!ptr)
        {
            throw new Exception("Cairo surface creation error.");
        }
    }

    override bool destroyPtr(){
        if(ptr){
            cairo_surface_destroy(ptr);
            return true;
        }

        return false;
    }
}
