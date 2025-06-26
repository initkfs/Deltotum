module api.dm.com.graphic.com_font;

import api.dm.com.com_result : ComResult;
import api.dm.com.com_destroyable : ComDestroyable;
import api.dm.com.graphic.com_surface : ComSurface;

/**
 * Authors: initkfs
 */
enum ComFontHinting
{
    none,
    normal,
    light,
    mono
}

interface ComFont : ComDestroyable
{
    
nothrow:

    ComResult renderFont(
        ComSurface targetSurface,
        const(dchar[]) text,
        ubyte fr, ubyte fg, ubyte fb, ubyte fa,
        ubyte br, ubyte bg, ubyte bb, ubyte ba);

    ComResult load(string path, double size);
    string getFontPath();
    double getFontSize();
    double getMaxHeight();
    ComResult setHinting(ComFontHinting hinting);

}
