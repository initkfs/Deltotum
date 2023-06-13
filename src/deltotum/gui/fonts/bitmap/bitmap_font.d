module deltotum.gui.fonts.bitmap.bitmap_font;

import deltotum.kit.sprites.textures.texture : Texture;
import deltotum.gui.fonts.glyphs.glyph : Glyph;

/**
 * Authors: initkfs
 */
class BitmapFont : Texture
{
    Glyph[] glyphs;

    Glyph placeholder;

    this(Glyph[] glyphs = null)
    {
        this.glyphs = glyphs;
    }

}
