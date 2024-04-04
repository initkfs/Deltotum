module dm.com.graphics.com_image;

import dm.com.platforms.results.com_result : ComResult;
import dm.com.graphics.com_surface : ComSurface;
import dm.com.lifecycles.destroyable : Destroyable;

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
