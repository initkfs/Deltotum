module app.dm.sys.cairo.cairo_context;

import app.dm.sys.cairo.base.cairo_object_wrapper : CairoObjectWrapper;
import app.dm.sys.cairo.cairo_surface: CairoSurface;
import app.dm.sys.cairo.libs;

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

    override bool disposePtr(){
        if(ptr){
            cairo_destroy(ptr);
            return true;
        }

        return false;
    }
}
