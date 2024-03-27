module dm.com.graphics.com_image;

import dm.com.platforms.results.com_result : ComResult;
import dm.com.graphics.com_surface : ComSurface;
import dm.com.lifecycles.destroyable : Destroyable;

/**
 * Authors: initkfs
 */
interface ComImage : Destroyable
{
    ComResult load(string path) nothrow;
    ComResult load(const(void[]) contentRaw) nothrow;
    ComResult toSurface(out ComSurface toSurface) nothrow;
    ComResult savePNG(ComSurface surface, string path) nothrow;
}
