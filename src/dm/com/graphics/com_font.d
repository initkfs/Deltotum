module dm.com.graphics.com_font;

import dm.com.platforms.results.com_result : ComResult;
import dm.com.lifecycles.destroyable : Destroyable;
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
    ComResult render(
        ComSurface targetSurface,
        const char* text,
        ubyte fr, ubyte fg, ubyte fb, ubyte fa,
        ubyte br, ubyte bg, ubyte bb, ubyte ba);

    ComResult fontPath(out string path);
    ComResult fontSize(out size_t size);
    ComResult setHinting(ComFontHinting hinting);

}
