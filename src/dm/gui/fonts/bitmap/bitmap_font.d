module dm.gui.fonts.bitmap.bitmap_font;

import dm.kit.sprites.textures.texture : Texture;
import dm.gui.fonts.glyphs.glyph : Glyph;

/**
 * Authors: initkfs
 */
class BitmapFont : Texture
{
    //TODO hash map
    Glyph[] glyphs;

    Glyph placeholder;

    this(Glyph[] glyphs = null)
    {
        this.glyphs = glyphs;
    }

}
