module deltotum.ui.texts.fonts.bitmap.bitmap_font;

import deltotum.display.textures.texture : Texture;
import deltotum.i18n.langs.glyph : Glyph;

/**
 * Authors: initkfs
 */
class BitmapFont : Texture
{

    @property Glyph[] glyphs = [];

    this(Glyph[] glyphs)
    {
        super();
        this.glyphs = glyphs;
    }

}
