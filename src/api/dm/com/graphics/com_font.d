module api.dm.com.graphics.com_font;

import api.dm.com.com_result : ComResult;
import api.dm.com.com_destroyable : ComDestroyable;
import api.dm.com.graphics.com_surface : ComSurface;

/**
 * Authors: initkfs
 */

interface ComFont : ComDestroyable
{

nothrow:

    ComResult renderFont(
        ComSurface targetSurface,
        const(dchar[]) text,
        ubyte fr, ubyte fg, ubyte fb, ubyte fa,
        ubyte br, ubyte bg, ubyte bb, ubyte ba);

    ComResult create(string path, uint size);

    string getFontPath();
    uint getFontSize();
    uint getMaxHeight();

}
