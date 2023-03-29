module deltotum.ui.fonts.bitmap.bitmap_font;

import deltotum.toolkit.display.textures.texture : Texture;
import deltotum.ui.fonts.glyphs.glyph : Glyph;

/**
 * Authors: initkfs
 */
class BitmapFont : Texture
{
    Glyph[] glyphs;

    this(Glyph[] glyphs = [])
    {
        this.glyphs = glyphs;
    }

}
