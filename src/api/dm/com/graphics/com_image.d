module api.dm.com.graphic.com_image;

import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.com.graphic.com_surface : ComSurface;
import api.dm.com.destroyable : Destroyable;

/**
 * Authors: initkfs
 */
interface ComImage : Destroyable
{
    nothrow: 
    
    ComResult load(string path);
    ComResult load(const(void[]) contentRaw);
    ComResult toSurface(out ComSurface toSurface);
    ComResult savePNG(ComSurface surface, string path);
}
