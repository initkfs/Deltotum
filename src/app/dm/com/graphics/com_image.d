module app.dm.com.graphics.com_image;

import app.dm.com.platforms.results.com_result : ComResult;
import app.dm.com.graphics.com_surface : ComSurface;
import app.dm.com.destroyable : Destroyable;

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
