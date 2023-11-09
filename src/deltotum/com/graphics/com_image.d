module deltotum.com.graphics.com_image;

import deltotum.com.platforms.results.com_result : ComResult;
import deltotum.com.graphics.com_surface : ComSurface;
import deltotum.com.lifecycles.destroyable : Destroyable;

/**
 * Authors: initkfs
 */
interface ComImage : Destroyable
{
    ComResult load(string path) nothrow;
    ComResult load(const(void[]) contentRaw) nothrow;
    ComResult toSurface(out ComSurface toSurface) nothrow;
}
