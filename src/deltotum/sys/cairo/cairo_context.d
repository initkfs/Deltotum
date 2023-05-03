module deltotum.sys.cairo.cairo_context;

import deltotum.sys.cairo.base.cairo_object_wrapper : CairoObjectWrapper;
import deltotum.sys.cairo.cairo_surface: CairoSurface;
import deltotum.sys.cairo.libs;

/**
 * Authors: initkfs
 */
class CairoContext: CairoObjectWrapper!cairo_t
{
    this(CairoSurface surface)
    {
        assert(surface);
        ptr = cairo_create(surface.getObject);
        if (!ptr)
        {
            throw new Exception("Cairo context creation error.");
        }
    }

    override bool destroyPtr(){
        if(ptr){
            cairo_destroy(ptr);
            return true;
        }

        return false;
    }
}
