module api.dm.com.graphic.com_font;

import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.com.destroyable : Destroyable;
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

interface ComFont : Destroyable
{
    
nothrow:

    ComResult renderFont(
        ComSurface targetSurface,
        const(dchar[]) text,
        ubyte fr, ubyte fg, ubyte fb, ubyte fa,
        ubyte br, ubyte bg, ubyte bb, ubyte ba);

    ComResult load(string path, double size);
    ComResult getFontPath(out string path);
    ComResult getFontSize(out double size);
    ComResult setHinting(ComFontHinting hinting);
    ComResult getMaxHeight(out double size);

}
