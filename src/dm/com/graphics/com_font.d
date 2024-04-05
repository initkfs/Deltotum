module dm.com.graphics.com_font;

import dm.com.platforms.results.com_result : ComResult;
import dm.com.destroyable : Destroyable;
import dm.com.graphics.com_surface : ComSurface;

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

    ComResult load(string path, size_t size);
    ComResult getFontPath(out string path);
    ComResult getFontSize(out size_t size);
    ComResult setHinting(ComFontHinting hinting);

}
