module api.dm.com.graphic.com_image;

import api.dm.com.com_result : ComResult;
import api.dm.com.graphic.com_surface : ComSurface;
import api.dm.com.com_destroyable : ComDestroyable;

/**
 * Authors: initkfs
 */
interface ComImage : ComDestroyable
{
    nothrow: 
    
    ComResult load(string path);
    ComResult load(const(void[]) contentRaw);
    ComResult toSurface(out ComSurface toSurface);
    ComResult savePNG(ComSurface surface, string path);
}
