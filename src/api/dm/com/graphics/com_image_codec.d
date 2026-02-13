module api.dm.com.graphics.com_image_codec;

import api.dm.com.com_result : ComResult;
import api.dm.com.graphics.com_surface : ComSurface;
import api.dm.com.com_destroyable : ComDestroyable;

/**
 * Authors: initkfs
 */
interface ComImageCodec : ComDestroyable
{
nothrow:

    bool isSupport(const(ubyte[]) buff);
    bool isSupport(string path);

    ComResult load(string path, ComSurface surface);
    ComResult load(const(ubyte[]) contentRaw, ComSurface surface);
    ComResult save(string path, ComSurface surface);
}
